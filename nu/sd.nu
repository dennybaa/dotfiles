#!/usr/bin/env -S nu --stdin
use lib.nu *

export def sd [
    --prompt (-p)       # Prompt and show change if updating
    pattern: string     # Regex pattern to use
    replace: string     # Replace string
    ...files: string    # Files to update
] {
    let $stdin = if not (is-terminal --stdin) { $in } else { null }

    # find and replace, prepare outputs record of files
    for $file in ($files | uniq) {
        # can not process stdin, since it's not provided!
        if ( $stdin == null and $file == "-" ) { continue }
        let content: string = if ( $file == "-" ) { $stdin } else { $file | open }
        let modified: string = $content | str replace --multiline -r $pattern $replace

        # skip nothing to change
        if ($content == $modified) { continue }

        if ($file == "-") {
            if ($prompt) {
                let tempfile = mktemp --dry -t
                $modified | save $tempfile
                do --ignore-errors { $content | ^delta --file-transformation $"s|($tempfile | str trim -l -c '/')|stdout|" - $tempfile }
                rm $tempfile
            } else {
                print -n $modified
            }
        } else {
            if ($prompt) {
                do --ignore-errors { $modified | ^delta $file --file-transformation $"s|^-$|($file)|" - }
                gum print "File is about to be updated, accept changes?"
                try {
                    gum confirm
                } catch {|e|
                    if ($e.exit_code > 0) { continue }
                }
            }
            $modified | save -f $file
        }
    }
}

# A helper script inspired by https://github.com/chmln/sd
export def main [
    --prompt (-p)       # Prompt and show change if updating
    pattern: string     # Regex pattern to use
    replace: string     # Replace string
    ...files: string    # Files to update
] {
    sd --prompt=$prompt $pattern $replace ...$files
}
