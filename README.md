# Workstation Setup Guide

Setting up a workstation takes three steps:

1. **Bootstrap** – Install Nix, mise, and the `nix/bootstrap` profile ([`bootstrap.sh`](bootstrap.sh))
2. **Deploy** – Stow the shared dotfiles and apply the system configuration (`mise run deploy`)
3. **Provision** – Install host packages and the Nix profile for this machine (`mise run provision:desktop`)

## Prerequisites

This setup requires the [dennybaa/dotfiles](https://github.com/dennybaa/dotfiles) repository. Install Git and clone the repository:

```shell
sudo apt install git -y

# Clone the repository
cd ~ && git clone git@github.com:dennybaa/dotfiles.git

# Alternative: clone via HTTPS
# cd ~ && git clone https://github.com/dennybaa/dotfiles.git
```

## Bootstrap

[`bootstrap.sh`](bootstrap.sh) installs Nix (if missing), mise into `~/.local/bin`, and the
`nix/bootstrap` profile. It also seeds `~/.config/mise/config.local.toml`, which holds
packages for this machine only and is never versioned.

```shell
cd ~/dotfiles && ./bootstrap.sh
```

> **✅ Action required:** Before a relogin happens, the Nix bootstrap profile is not sourced. To continue setup in this case, running the command below is **required**:
> ```shell
> . /etc/profile.d/nix.sh
> ```

## Deploy

Stows `bundle-default` (shell, editors, the global mise config) and applies the templated system
files (`~/.config/mise`, `~/.config/nix`, `~/.config/systemd`) with `mise dot apply`:

```shell
mise run deploy
```

> **📝 Note:** The token comes from gopass (`github/public-api-token`) through fnox. When no store
> is available, mise asks for it once and keeps it in memory for that run — nothing is written to
> disk:
>
> ```
> Enter bootstrap secret github_token
> > ********
> ```
>
> `github_token` is the logical name declared in `[bootstrap.secrets]`; it is read from the
> `GITHUB_USER_TOKEN_PUBLIC` environment variable. Used by Nix and Mise to authenticate GitHub API
> requests (higher rate limits instead of anonymous access).

## Provision

With the configuration deployed, install this machine's packages and Nix profile. Two presets
are available:

- **minimal** – a basic set of packages (zsh, tmux, etc.)
- **desktop** – a full workstation with APT, Flatpak, and Nix packages

```shell
mise run provision:minimal
# OR
mise run provision:desktop

# Additionally: browser and file associations
mise run 'setup:desktop:*'

# Desktop applications (happ + sing-box DNS reset) are stowed separately
# from the presets; this also enables their systemd user units
mise run stow apps-desktop
```

> **📝 NOTE:** Use `--upgrade` (or `-u`) to also upgrade installed packages and flake inputs.

## Configuration

View available mise tasks:

```shell
mise tasks
```

## Packages

Packages are declared in mise config (`[bootstrap.packages]`), with their repositories in
`[bootstrap.apt.sources]`:

- `stow/bundle-default/.config/mise/config.toml` – base packages, on every machine
- `stow/bundle-desktop/.config/mise/conf.d/desktop-packages.toml` – desktop-only packages and apt sources
- `~/.config/mise/config.local.toml` – packages for this machine only (never versioned)

```shell
# what is declared vs what is installed
mise bootstrap packages status

# preview, then install the missing packages (--update also refreshes apt metadata)
mise bootstrap packages apply --dry-run
mise bootstrap packages apply

# upgrade the declared packages that are already installed
mise bootstrap packages upgrade

# add a package to the shared config (the stowed ~/.config/mise/config.toml) and install it
mise bootstrap packages use -g flatpak-user:org.example.App
# machine-local packages go into ~/.config/mise/config.local.toml by hand (never versioned)
```

> **📝 NOTE:** `mise bootstrap packages prune` uninstalls packages no config declares; run it with
> `--dry-run` first.

### Nix Profile

A single profile approach is recommended: `nix/desktop`, `nix/minimal`, etc.

Install a profile:

```shell
mise run nix desktop
```

After installing the main profile, clean up the bootstrap profile to avoid overlap (recommended, but not necessary):

```shell
mise run nix:rm bootstrap
```

> 📝 **Note:** Use `-u/--update` to refresh flake versions.
