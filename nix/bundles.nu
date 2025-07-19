const defaultRelease = "25.05"
const _bundles = {
    desktop: [
        keepassxc
        mailspring
        megasync
        syncthing
        vscode
    ]
    devops: [
        devbox
        just
        podman
        toolbox
        zoxide
    ]
}

const bundles = {
    cli: [
        ...$_bundles.devops
    ]
    desktop: [
        ...$_bundles.devops
        ...$_bundles.desktop
    ]
}
