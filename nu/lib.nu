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
}


export def "gum print" [
    message: string
    --color=44
    --padding="0 0"
] {
    ^gum style --padding $padding --foreground $color $message
}

# Check if sudo password is required to be acquired
export def "sudo password-required" []: nothing -> bool  {
    (^sudo -n true | complete).exit_code > 0
}

# Use sudo tee to write/append to a file
export def "sudo tee" [
    path: string
    --message (-m): string
    --append (-a)=false
    --silent=true
]: string -> nothing {
    let teeopts = [ (if ($append) {"-a"}) $path ]
        | where ($it | is-not-empty)
    let content = $in
    sudo acquire $message
    try {
        if ($silent == true) {
            $content | ^sudo tee ...$teeopts o+e> $null_device
        } else {
            $content | ^sudo tee ...$teeopts
        }
    } catch {|e|
        gum print $e.msg; gum style --foreground $color.red 'Operation failed!'; exit $e.exit_code
    }
}

# acquire sudo privileges
export def "sudo acquire" [message] {
    # Inform of operation to be carried out
    gum style --padding="1 0 0 0" --foreground $color.default $message
    if (sudo password-required) {
        gum print --color $color.sudo "🧙 Acquiring privileges to perform action!"
        try { ^sudo -i true } catch {|e|
            gum style --foreground $color.red 'Operation failed!'
            exit $e.exit_code
        }
    }
}

# Write a gpg key
export def "write gpg-key" [
    path: string
    --keyURL: string = ""
]: nothing -> bool {
    if not ($path | path exists) and ($keyURL | is-not-empty) {
        http get $keyURL | do {
            sudo acquire $'Writing gpg key into ($path)...'
            $in | ^sudo gpg --dearmor -o $path
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
    $update | to yaml | sudo tee -m $"Writing ($file_name).sources ..." $path
    return true
}

export def "sudo apt-update" [] {
    sudo acquire "Updating Apt sources..."
    ^sudo apt-get update
}
