# Setup workstation

**Clone dotfiles:**

```shell
#! UPDATE the bellow to match your specfifc settings
git config --global user.email "dennybaa@gmail.com"
git config --global user.name "Denis Baryshev"

git clone git@github.com:dennybaa/dotfiles.git

#! for public clones use:
# git clone https://github.com/dennybaa/dotfiles.git
```

## Packages setup (system + nix)

### Install OS packages (apt/debian)

```shell
~/dotfiles/packages/tools.sh

~/dotfiles/packages/desktop.sh
```

### Install Nix profile packages

Instructions on how to install nix https://nix.dev/install-nix.html

**Get nix and clone dotfiles:**
```shell
if (! which nix >& /dev/null); then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon

    # enable flakes
    mkdir -p ~/.config/nix
    echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
fi
```

**Update github token:**

Place the bellow configs into `~/.config/nix/nix.conf`:


```shell
gh auth login
```

```
mkdir -p ~/.config/nix && echo "access-tokens = github.com=$(gh auth token)" >> ~/.config/nix/nix.conf && chmod 600 ~/.config/nix/nix.conf
```

**Get packages:**
```shell
# install default tools
{ cd ~/dotfiles/nix/tools && nix profile install .; }

# install desktop apps
{ cd ~/dotfiles/nix/desktop && nix profile install .; }
```

**Upgrade packages:**
```shell
nix profile upgrade nix/tools
nix profile upgrade nix/desktop
```
