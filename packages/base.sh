#!/usr/bin/bash
set -e

sudo -i true
sudo apt update
sudo apt install -y \
    git \
    bind9-dnsutils tcpdump wireguard \
    uidmap \
    zsh vim direnv stow \
    htop atop tree lsof \
    wget curl

# install nix
if (! which nix >& /dev/null); then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon

    # enable flakes
    mkdir -p ~/.config/nix
    echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
fi
