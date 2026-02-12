#!/usr/bin/env nu
use lib.nu
source ../packages.nu


# Install packages
def main [] {
}


# Install flatpak packages
def 'main flatpak' [
    bundle: string          # bundle to install (base/desktop etc)
    ...extra: string        # extra bundles to install
] {
    $FlatpakPackages | select -o ...[$bundle, ...$extra] | items {|bundle,  pkgs|
        if ($pkgs | is-not-empty) {
            let args = [--spinner=minidot --spinner.foreground=44 --show-output]
            gum spin ...$args --title $'Installing flatpak bundle ($bundle)...' -- flatpak install -y ...$pkgs
        }
    } | ignore
}


# Add apt sources and install gpg keys into keyrings directory
def 'main apt add-sources' [] {
    mut updated = false
    for i in ($AptSources | transpose name items) {
        $i.items | lib apt add-sources $i.name | if ($in) { $updated = true }
    }
    if ($updated) { lib sudo apt-update }
}
