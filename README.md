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
    cd ~/dotfiles && ./bootstrap.sh
    ```

    > **✅ Action required:** Before a relogin happens, the Nix bootstrap profile is not sourced. To continue setup in this case, running the command below is **required**:
    > ```shell
    > . /etc/profile.d/nix.sh
    > ```

2. Run the post-Nix bootstrap tasks:

    ```shell
    mise run bootstrap
    ```

    > **📝 Note:** The bootstrap process may prompt for local secret values, like the example below:
    >
    > ```
    > Enter your GitHub Personal Access Token (for public repositories, CTRL+D to submit)
    > >>>
    > ```
    >
    > **`GitHub Personal Access Token for public repositories`**
    > : Used by Nix and Mise to authenticate API requests when downloading from GitHub (increases rate limits and avoids anonymous access restrictions).
    

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
mise run provision:minimal
# OR
mise run provision:desktop

# Additionally
mise run 'setup:desktop:*'
```

> **📝 NOTE:** Use `--update` (or `-u`) to refresh installed packages, including Flatpak and Nix.

## Packages

System package configuration is defined in [nu/packages.nu](nu/packages.nu):

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
mise run nix desktop
```

After installing the main profile, clean up the bootstrap profile to avoid overlap (recommended, but not necessary):

```shell
mise run nix:rm bootstrap
```

> 📝 **Note:** Use `-u/--update` to refresh flake versions.
