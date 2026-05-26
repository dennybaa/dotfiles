# systemd (systemctl --user) helper utilities
#

# List user unit files
export def "list unit-files" [
    --state (-s): string = ""
] {
    mut opts = []
    if $state != "" { $opts ++= ["--state", $state] }

    ^systemctl --user list-unit-files --no-legend ...$opts | from ssv -nm 1 | rename unit state preset
}

# Link user unit files list
#
export def "link units" [
    --path (-p): string = ""  # prepend path to add to units (eg, ~/.nix-profile/share/systemd/user)
    units: list<string>
] {
    # Get existing nix unit file paths
    let unit_paths = $units
        | each { |unit|
            let full = path join $path $unit
            if ($full =~ '\*') { glob $full } else { $full } # process globs if present
        }
        | flatten # since globs can result in multiple paths, flatten the list
        | where { |path| $path | path exists }

    if ($unit_paths | length) == 0 { return }

    # Check if there was an error, but ignore "File exists"
    let linked = (^ln -s ...( $unit_paths) ~/.config/systemd/user | complete)
    if ($linked.exit_code != 0 and ($linked.stderr | find -mr 'File exists\n' | is-empty)) {
        print -e $linked.stderr
        exit $linked.exit_code
    }
}

# Fix dereferenced systemd unit link
def fix-dereferenced [
    src: string  # source systemd unit path
] {
    # Fix dereferenced destinations
    match $src {
        $s if ($s | str starts-with '/nix/store') => {
            $s | str replace -r '/nix/store/[^/]+/' $"($env.HOME)/.nix-profile/"
        }
        _ => $src
    }
}

# Enable user units (~/.config/systemd/user) if they are disabled
# Unfortunately, systemctl dereferences symlinks, which will bring us to broken links after an upgrade.
#    Created symlink .../.config/systemd/user/sockets.target.wants/podman.socket → /nix/store/kdqhmyvzbx5pyc0lkicrjj387j21p9w3-podman-5.7.0/share/systemd/user/podman.socket.
#
# Thus we need recreate them after run.
export def "enable units" [
    units: list<string>
] {
    let enable = list unit-files -s linked,disabled | where {|i| $i.unit in $units }
    if ($enable | length) == 0 { return }   

    # Try to enable units, but fail in case of errors (eg. a missing unit file)
    let output = try {
        ^systemctl --user enable ...($enable.unit) | complete

    } catch { |e|
        ## TODO: RED COLOR
        print -e $e.raw; exit $e.exit_code       
    }

    # Recreate symlinks in case we see that the source has been dereferenced to /nix/store
    for link in ($output.stderr | parse --regex 'Created symlink (?<dst>.+) → (?<src>.+)\.') {
        let fixed = fix-dereferenced $link.src
        if ($fixed != $link.src) { ln -sf $fixed $link.dst }
        print -e $"Created symlink ($link.dst) → ($fixed)."
    }
    ^systemctl --user daemon-reload
}

# Disable user units (~/.config/systemd/user) if they are enabled
# Note: systemctl cleans out the source ~/.config/systemd/user/* units if they are symlinks!
export def "disable units" [
    units: list<string>
] {
    let disable = list unit-files -s enabled | where {|i| $i.unit in $units }
    if ($disable | length) == 0 { return }
    ^systemctl --user disable ...($disable.unit)
    ^systemctl --user daemon-reload
}
