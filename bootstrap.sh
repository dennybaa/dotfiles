#!/usr/bin/bash
set -e

bootstrapped=""
if (! sudo -n true &> /dev/null); then
    echo "Acquiring sudo privileges..."
    sudo -i true
fi


# install nix
if (! which nix >& /dev/null); then
    echo "Bootstrapping nix..."
    sudo apt update && sudo apt install -y git wget curl
    curl -L https://nixos.org/nix/install | sh -s -- --daemon

    # enable flakes
    mkdir -p ~/.config/nix
    echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
    bootstrapped=y
fi


# install nix/base profile 
if ( ! nix profile list | grep -wq 'nix/base' ); then
    echo "Installing nix/base profile..."
    (cd nix/base && nix profile install .)
    nix profile list
    bootstrapped=y
fi

if [ -z "$bootstrapped" ]; then
    echo "System is already bootstrapped!"
fi
