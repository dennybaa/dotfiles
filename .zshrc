. ~/.shell/functions

# We are not using global zprofile, so we need to populate env
. ~/.shell/env

# Load shell tools (cleanup functions in the end)
. ~/.shell/load && shell_cleanup


# k3d
k3d() {
    if [[ "$1" == "cluster" && "$2" == "create" ]]; then
        if [[ ! "$*" == *"--k3s-arg"* ]]; then
            command k3d "$@" --k3s-arg '--kubelet-arg=feature-gates=KubeletInUserNamespace=true@server:*'
            return
        fi
    fi
    command k3d "$@"
}
