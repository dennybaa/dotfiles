# Setup workstation

```shell
git clone dennybaa/dotfiles
```

# Setup nix and base packages

Instructions on how to install nix https://nix.dev/install-nix.html

Install nix:

```shell
# install nix

if (! which nix >& /dev/null); then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi
```

Setup:


```shell
# bootstrap nu
~/dotfiles/nix/bootstrap-nu.sh
```
