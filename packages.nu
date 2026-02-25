use std/util null_device
use nu/lib.nu

let APT_ARCH = $'(dpkg --print-architecture)'

# LSB helpers
let LSB = {
    ShortRelease: $'(lsb_release -rs e> $null_device)'
}


## Apt sources to populate
let AptSources = {
    warpdotdev: [
        {
            line: $"deb [arch=($APT_ARCH) signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main"
            keyURL: "https://releases.warp.dev/linux/keys/warp.asc"
        }
    ]
    megasync: [
        {
            line: $"deb [arch=($APT_ARCH) signed-by=/usr/share/keyrings/meagsync.gpg] https://mega.nz/linux/repo/xUbuntu_($LSB.ShortRelease)/ ./"
            keyURL: "https://mega.nz/keys/MEGA_signing.key"
        }
    ]
    github: [
        {
            line: $"deb [arch=($APT_ARCH) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"
            keyURL: "https://cli.github.com/packages/githubcli-archive-keyring.gpg"
        }
    ]
}

## APT packages bundles
let AptPackages = {
    base: [
        bind9-dnsutils
        tcpdump
        uidmap
        zsh
        vim
        direnv
        htop
        atop
        tree
        lsof
        syncthing
        gh
        libsecret-1-0
    ]
    desktop: [
        warp-terminal
        megasync
        syncthing-gtk
        transmission-gtk
        remmina
    ]
}

## Flatpak packages bundles
let FlatpakPackages = {
    desktop: [
        org.gimp.GIMP
        org.telegram.desktop
        com.slack.Slack
        us.zoom.Zoom
        com.brave.Browser
        com.rustdesk.RustDesk
        org.keepassxc.KeePassXC
    ]
}
