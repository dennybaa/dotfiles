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
