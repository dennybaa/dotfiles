#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. $SCRIPT_DIR/../scripts/lib.sh

# Flatpak applications
# --------------------

# Install flatpak packages
flatpak install -y \
    org.gimp.GIMP \
    org.telegram.desktop \
    com.slack.Slack \
    us.zoom.Zoom \
    com.brave.Browser \
    org.keepassxc.KeePassXC

# GNOME Crypto Resources (gcr) new way to manage ssh agent socket (/run/user/1000/gcr/ssh)
# Note!: set SSH_SOCKET_AUTH override in keepass after installation
flatpak override --user --filesystem=xdg-run/gcr org.keepassxc.KeePassXC
