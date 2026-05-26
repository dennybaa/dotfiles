use std/util null_device

# Predefined colors
export const spinnerDefault = [ --spinner=minidot --spinner.foreground=44 ]
export const color = {
    default: 6
    sudo: 202
    white: 7
    cyan: 6
    red: 9
    green: 42
    lightBlue: 44
    warning: 214
    yellow: 214
}

export def git_root [] {
    ^git rev-parse --show-toplevel | str trim
}

# Run gum style to print a line
export def "gum print" [
    message: string
    --color=$color.lightBlue    # Specify color (default: light blue)
    --padding (-p)="0 0"        # Specify padding
    --no-newline (-n)           # Omit newline if -n is provided
] {
    ^gum style --padding $padding --foreground $color $message |
        | str trim -rc "\n" | if $no_newline { print -n } else { print }
}

# Check if sudo password is required to be acquired
export def "sudo password-required" []: nothing -> bool  {
    (^sudo -n true | complete).exit_code > 0
}

# Acquire sudo privileges if not yet available
export def "sudo acquire" [
    --prompt (-p): string = ""    # Prompt message before aquiring privileges
    block?: closure               # Run sudo code block. Note! sudo is required for commands inside the block.
] {
    # Inform of operation to be carried out
    if ($prompt | is-not-empty) { gum style --padding="1 0 0 0" --foreground $color.default $prompt }
    if (sudo password-required) {
        gum print --no-newline --color $color.sudo "🧙 Privileges required. "
        try { ^sudo -i true } catch {|e|
            gum style --foreground $color.red 'Operation failed!'
            exit $e.exit_code
        }
    }

    # Run sudo code block
    if ($block != null) { do $block }
}

# Write a gpg key
export def "write gpg-key" [
    path: string
    --keyURL: string = ""
]: nothing -> bool {
    if not ($path | path exists) and ($keyURL | is-not-empty) {
        let gpgKey = http get $keyURL
        sudo acquire -p $'Writing gpg key into ($path)...' {
            $gpgKey | ^sudo gpg --dearmor -o $path
            gum print --color=$color.green $"✅ Added ($path)"
        }
        return true
    }
    return false
}

# Create/update a .source file in /etc/apt/sources.list.d,
# also assist to write a gpg key when _keyURL is provided.
export def "apt add-sources" [
    file_name: string
    source: record
]: nothing -> bool {
    let path = $'/etc/apt/sources.list.d/($file_name).sources'
    let hiddenKeys = $source | columns | where {|c| $c | str starts-with '_'}
    mut rs = false

    # Current and the new computed value
    let current = try { open $path | from yaml } catch { {} }
    let update = $current | merge {Types: 'deb', ...($source | reject ...$hiddenKeys)}

    # Helper to write a gpg key from _keyURL
    $source._keyURL | if ($in | is-not-empty) {
        if (write gpg-key --keyURL=$in $update."Signed-By") {
            $rs = true
        }
    }

    if $current == $update { return $rs }
    # Update a .sources file
    sudo acquire -p $"Writing ($file_name).sources ..." {
        $update | to text | ^sudo tee $path
    }
    return true
}
