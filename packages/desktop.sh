#!/bin/bash
set -e
# sudo -i true
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. $SCRIPT_DIR/../scripts/lib.sh

## APT applications (ubuntu/debian/pop-os)
## ---------------------------------------

# Sources...
apt_sources_add \
    "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" \
    warpdotdev.list \
    https://releases.warp.dev/linux/keys/warp.asc

apt_sources_add \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/meagsync.gpg] https://mega.nz/linux/repo/xUbuntu_$(lsb_release -rs 2>/dev/null)/ ./" \
    megasync.list \
    https://mega.nz/keys/MEGA_signing.key

# Get apps...
sudo -i true
sudo apt update
sudo apt install -y \
    warp-terminal \
    megasync \
    syncthing-gtk \
    transmission-gtk \
    keepassxc \
    remmina

# Flatpak applications
# --------------------

# install flatpak packages
flatpak install -y \
    com.brave.Browser \
    org.gimp.GIMP \
    com.getmailspring.Mailspring \
    org.telegram.desktop \
    com.slack.Slack \
    us.zoom.Zoom
