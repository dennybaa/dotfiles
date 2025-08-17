#!/usr/bin/bash

sudo -i true

sudo apt update
sudo apt install -y \
    git git-crypt \
    bind9-dnsutils tcpdump wireguard \
    zsh neovim direnv stow \
    htop atop tree lsof \
    wget curl
