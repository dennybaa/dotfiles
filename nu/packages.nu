use std/util null_device

let os = {
    arch:  $'(^dpkg --print-architecture)'
}

## Apt sources to populate
let _AptSources = {
    megaio: {
        URIs: 'https://mega.nz/linux/repo/xUbuntu_24.04/'
        Suites: './'
        'Signed-By': '/etc/apt/keyrings/meganz-archive-keyring.gpg'
        _keyURL: 'https://mega.nz/keys/MEGA_signing.key'
    }
    warpdotdev: {
        URIs: 'https://releases.warp.dev/linux/deb'
        Architectures: $os.arch
        Suites: 'stable'
        Components: 'main'
        'Signed-By': '/etc/apt/trusted.gpg.d/warpdotdev.gpg'
        _keyURL: 'https://releases.warp.dev/linux/keys/warp.asc'
    }
    zerotier: {
        URIs: 'http://download.zerotier.com/debian/bookworm'
        Suites: 'bookworm'
        Components: 'main'
        'Signed-By': '/usr/share/keyrings/zerotier-debian-package-key.gpg'
        _keyURL: 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/main/doc/contact%40zerotier.com.gpg'
    }
}

## Bundle specific source files
let AptSources = {
    default: {}
    desktop: ($_AptSources | select ...[megaio warpdotdev zerotier])
}

## APT packages bundles
let AptPackages = {
    default: [
        bind9-dnsutils
        tcpdump
        uidmap
        zsh
        direnv
        htop
        atop
        tree
        lsof
        grc
        tmux
    ]
    desktop: [
        warp-terminal
        megasync
        syncthing-gtk
        transmission-gtk
        remmina
        libsecret-1-0
        syncthing
        zerotier-one
    ]
}

## Flatpak packages bundles
let FlatpakPackages = {
    default: {}
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
