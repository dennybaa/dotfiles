#!/usr/bin/bash
set -e

bootstrapped=""
if ! sudo -n true &> /dev/null; then
    echo "Acquiring sudo privileges..."
    sudo -i true
fi

# Install Nix
if [ ! -e /etc/profile.d/nix.sh ]; then
    echo "Bootstrapping nix..."
    sudo apt update && sudo apt install -y git sed wget curl zsh
    curl -L https://nixos.org/nix/install | sh -s -- --daemon

    # enable flakes
    mkdir -p ~/.config/nix
    echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
    bootstrapped=y
fi

# Fix nix provided /etc/zshrc (while the correct one /etc/zsh/zshrc), so source /etc/zshrc
if zsh -ixc : 2>&1 | grep -q 'etc/zsh/' && [ -f /etc/zshrc ]; then
    if ! grep -q '^\. \/etc\/zshrc' /etc/zsh/zshrc; then
        echo -e "\n# Compat include\n. /etc/zshrc\n# Compat include Ends" | sudo tee -a /etc/zsh/zshrc >/dev/null
    fi
fi

# Load nix profile paths and add nix/base profile
. /etc/profile.d/nix.sh
if ! nix profile list | grep -wq 'nix/bootstrap'; then
    echo "Adding nix/bootstrap profile..."
    # lower priority in comparison to other profiles
    cd nix/bootstrap && nix profile add . --priority 6
    cd - >/dev/null

    nix profile list
    bootstrapped=y
fi

# Fix nix provided /etc/zshrc (while the correct one /etc/zsh/zshrc), so source /etc/zshrc
if zsh -ixc : 2>&1 | grep -q 'etc/zsh/' && [ -f /etc/zshrc ]; then
    if ! grep -q '^\. \/etc\/zshrc' /etc/zsh/zshrc; then
        echo -e "\n# Compat include\n. /etc/zshrc\n# Compat include Ends" | sudo tee -a /etc/zsh/zshrc >/dev/null
    fi
fi

if [ -z "$bootstrapped" ]; then
    echo "System is already bootstrapped!"
fi
