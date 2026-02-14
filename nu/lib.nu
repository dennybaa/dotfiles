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

# Check if sudo password is requied to be aquired
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
    sudo aquire $message
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

# Aquire sudo privileges
export def "sudo aquire" [message] {
    # Inform of operation to be carried out
    gum style --padding="1 0 0 0" --foreground $color.default $message
    if (sudo password-required) {
        gum print --color $color.sudo "👷 Aquiring privileges to perform action!"
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
            sudo aquire $'Writing gpg key into ($path)...'
            $in | ^sudo gpg --dearmor -o $path
            gum print --color=$color.green $"✅ Added ($path)"
        }
        return true
    }
    return false
}

# Add source items (passed as input) into a source file.
# Returns true if source items have been added.
export def "apt add-sources" [
    name: string # apt file name
]: list<record<line:string>> -> bool {
    let input = $in
    let path = $'/etc/apt/sources.list.d/($name).list'
    mut rs = false
    mut updated: list<record<line: string>> = []

    $input | if ($path | path exists) {
        let conent = $path | open | lines # existing content
        # build an update (consists of lines to add into source file)
        for i in $input {
            $conent
            | where $it == $i.line
            | if ($in | is-empty) { $updated = $updated | append $i } # no matches found, source file must be updated
        }
    } else { $updated = $in }

    # Write lines updates (or new ones) into a source file
    if ($updated | is-not-empty) {
        # We don't rollback since we update (revert can be proceeded manually) if needed
        # Join and sudo tee the update
        $updated.line | str join "\n" | $"($in)\n" 
            | do {
                sudo tee --append=true -m $'Adding deb sources...' $path
            }

        gum print --color=$color.green $"✅ Added ($path)"
        $rs = true
    }

    # Write a gpg file if needed
    for i in $input {
        let keyURL = $i | get -o keyURL
        $i.line | parse -r '.*?signed-by=(?P<keypath>[\w\/.]+).*' |
            if ($in | is-not-empty) and ($keyURL | is-not-empty) {
                write gpg-key --keyURL=($i | get -o keyURL) ($in.keypath | first)
                    | if ($in) { $rs = true }
            }
    }
    return $rs
}

export def "sudo apt-update" [] {
    sudo aquire "Updating Apt sources..."
    ^sudo apt update
}
