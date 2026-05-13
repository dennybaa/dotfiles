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
    bundle: string          # bundle to install (default/desktop etc)
    ...extra: string        # extra bundles to install
] {
    let update = if ($update) { ['--or-update'] } else { [] }
    let bundles = $FlatpakPackages | select -o ...[$bundle, ...$extra]
    for e in ($bundles | items {|k, v| {bundle: $k, pkgs: $v}}) {
        if ($e.pkgs | is-not-empty) {
            lib gum print --padding="1 0 0 0" $'Installing Flatpak bundle ($e.bundle)...'
                ^flatpak install ...$update -y ...$e.pkgs
        }
   }
}


# Add apt sources and install gpg keys into keyrings directory
def 'main apt add-sources' [
    sources: record
]: nothing -> bool {
    mut updated = false
    for i in ($sources | transpose file_name source) {
        $updated = lib apt add-sources $i.file_name $i.source
    }
    return $updated
}

# Provision apt packages
def 'main apt' [
    --update (-u)           # Set to perform packages update
    bundle: string          # bundle to install (default/desktop etc)
    ...extra: string        # extra bundles to install
]: nothing -> nothing {
    # Refresh apt sources if needed
    mut aptUpdate = false

    # Add sources for all processed bundels
    let bundles = [$bundle, ...$extra]
    for b in $bundles {
        $AptSources | get $b | main apt add-sources $in |
            if ($in) { $aptUpdate = true }
    }

    # Refresh apt sources
    if ($update or $aptUpdate) { lib sudo apt-update }

    for b in $bundles {
        $AptPackages | get $b | if ($in | is-not-empty) {
            lib sudo acquire $'Installing Apt bundle ($b)...'
            ^sudo apt-get install -y ...$in
        }
    }
}
