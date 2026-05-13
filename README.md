# Workstation Setup Guide

Setting up a workstation involves two phases:
1. **Bootstrap** – Install Nix on a Debian-based system along with base tools
2. **Provision** – Install APT/Flatpak packages and apply configurations via [mise](https://mise.jdx.dev/lang/rust.html)

## Prerequisites

This setup requires the [dennybaa/dotfiles](https://github.com/dennybaa/dotfiles) repository. Install Git and clone the repository:

```shell
sudo apt install git -y

# Clone the repository
cd ~ && git clone git@github.com:dennybaa/dotfiles.git

# Alternative: clone via HTTPS
# cd ~ && git clone https://github.com/dennybaa/dotfiles.git
```

## Provision a Workstation

The provision phase installs software and applies system configurations. This is orchestrated by [mise](https://mise.jdx.dev) and uses:

- **`nu/install-packages.nu`** – Handles package operations: updating APT sources, installing APT and Flatpak packages
- **mise** – Executes configuration hooks

### Bootstrap

1. Run the bootstrap script to install Nix:

    ```shell
    cd ~/dotfiles && ./bootstrap.sh && . /etc/profile.d/nix.sh
    ```

2. Run the post-Nix bootstrap tasks:

    ```shell
    mise r bootstrap
    ```

3. **Configure GitHub token**

   > **Why this matters**: Prevents GitHub API rate limiting when package managers fetch sources.

   Create a fine-grained personal access token (PAT) at: https://github.com/settings/personal-access-tokens

   Then run:

   ```shell
   mise r setup:github-token
   ```

## Configuration

View available mise tasks:

```shell
mise tasks
```

### Provision a System Preset

Two system presets are available:

- **minimal** – Installs a basic set of packages (zsh, tmux, etc.)
- **desktop** – Full workstation with APT, Flatpak, and Nix packages

Run the appropriate command:

```shell
mise r provision:minimal

# OR

mise r provision:desktop
```

> **📌 NOTE:** Use `--update` (or `-u`) to refresh installed packages, including Flatpak and Nix.

## Packages

System package configuration is defined in [packages.nu](packages.nu):

- **`AptSources`** – Files for `/etc/apt/sources.list.d/` and optional GPG keys
- **`AptPackages`** and **`FlatpakPackages`** – Packages organized by type (base, desktop, etc.)

Install specific bundles:

```shell
mise r packages:apt default desktop
```

### Nix Profile

A single profile approach is recommended: `nix/desktop`, `nix/vps`, `nix/server`, etc.

Install a profile:

```shell
mise r nix desktop
```

After installing the main profile, clean up the bootstrap profile to avoid overlap:

```shell
mise r nix:rm bootstrap
```

> 📝 **Note:** Use `-u/--update` to refresh flake versions.
