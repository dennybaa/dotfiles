
declare -A colors
colors[default]=6
colors[red]=9
colors[gum]=212
# sudo: 202
# white: 7
# cyan: 6
# green: 42
# lightBlue: 44
# warning: 214

# Check if Secrets Service is available (true for Desktops)
function has-secrets-service() {
    dbus-send --session --dest=org.freedesktop.DBus --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null | grep -q org.freedesktop.secrets && \
        return 0 || return 1
}


function get-secret() {
    local storePath=~/.local/share/dotfiles/secrets
    local user="$1"

    if ( has-secrets-service ); then
        chezmoi secret keyring get --service=dotfiles --user="${user}" 2>/dev/null || :
    else
        # create store directory
        [ -d "${storePath}" ] || { mkdir -p "${storePath}" && chmod 700; }
        cat "${storePath}/${user}" 2>/dev/null || :
    fi
}

function set-secret() {
    local storePath=~/.local/share/dotfiles/secrets
    local user="$1" value="$2"

    if ( has-secrets-service ); then
        chezmoi secret keyring set --service=dotfiles --user="${user}" --value="${value}" 2>/dev/null || :
    else
        # create store directory (if needed)
        [ -d "${storePath}" ] || { mkdir -p "${storePath}" && chmod 700 "${storePath}"; }
        printf "%s" "${value}" > "${storePath}/${user}" && chmod 600 "${storePath}/${user}"
    fi
}
