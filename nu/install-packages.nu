#!/usr/bin/env nu
use lib.nu *
use std/util null_device
source ../packages.nu


# Install packages
def main [] {
}


# Provision flatpak packages
def 'main flatpak' [
    --update (-u)           # Set to perform packages update
    bundle: string          # bundle to install (base/desktop etc)
    ...extra: string        # extra bundles to install
] {
    let update = if ($update) { ['--or-update'] } else { [] }
    $FlatpakPackages | select -o ...[$bundle, ...$extra] | items {|bundle,  pkgs|
        if ($pkgs | is-not-empty) {
            [
                ...$spinnerDefault --padding "1 0 0 0" --title $'Installing Flatpak bundle ($bundle)...'
                --
                flatpak install ...$update -y ...$pkgs
            ] |
                gum spin ...$in | print
        }
    } | ignore
}


# Add apt sources and install gpg keys into keyrings directory
def 'main apt add-sources' []: nothing -> bool {
    mut updated = false
    for i in ($AptSources | transpose name items) {
        $i.items | lib apt add-sources $i.name |
            if ($in) { $updated = true }
    }
    if ($updated) { lib sudo apt-update }
    return $updated
}

# Provision apt packages
def 'main apt' [
    --update (-u)           # Set to perform packages update
    bundle: string          # bundle to install (base/desktop etc)
    ...extra: string        # extra bundles to install
]: nothing -> nothing {
    let updated = main apt add-sources
    # Refresh is needed
    if ($update and not $updated) { lib sudo apt-update }

    $AptPackages | select -o ...[$bundle, ...$extra] | items {|bundle,  pkgs|
        if ($pkgs | is-not-empty) {
            lib sudo aquire $'Installing Apt bundle ($bundle)...'
            ^sudo apt-get install -y ...$pkgs | print
        }
    } | ignore
}

# Provision (install/refresh or upgrade) nix/<profile>
export def 'main nix' [
    --update (-u)                       # Set to refresh from Nix Store and flake.lock, effectivly updates profile packages
    --output (-o): string = "default"   # Specify which package output to use (see flake.nix)
    profile: string                     # Profile to provision
] {
    let profile = $profile | str replace -r '.?/?nix/' ''
    let flake_output = '.' + if ($output == 'default') {''} else {$'#($output)'}

    let supported_outputs = nix flake show $"./nix/($profile)/flake.nix" --json e> $null_device
        | from json | $in.packages | transpose arch outputs
        | $in.outputs | columns

    if not ($output in $supported_outputs) {
        lib gum print --color=$color.red $"No output `($output)' in flake.nix for nix/($profile) profile!"
        exit 1
    }

    # profile exists
    let profiles = nix profile list --json  | from json | $in.elements | columns
    let profileExists = $'nix/($profile)' in $profiles

    if (not $update) {
        # Note! that changes to flake.nix might not
        lib gum print --padding="1 0 0 0" $'Installing nix/($profile) profile...'
        if ($profileExists) {
            $"Note: Changes in flake.nix might be not reflected if not tracked by git.\n      You can use --update (-u) to force profile update." |
                lib gum print --padding="0 0 1 0" --color=$color.warning $in
        }
        do { cd ./nix/($profile); nix profile install $flake_output }
    } else {
        lib gum print --padding="1 0 0 0" $'Upgrading nix/($profile) profile...'
        nix flake update --flake ./nix/($profile); nix profile upgrade nix/($profile)
    }
}
