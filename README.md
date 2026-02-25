# Workstation Setup Guide

Setting up a workstation involves two main phases:
1. **Bootstrap** – Install Nix on a Debian-based system and the base tools (populating nix/base)
2. **Provision** – Install APT/Flatpak packages and apply configurations via [mise](https://mise.jdx.dev/lang/rust.html)

## Prerequisites

The setup process requires the [dennybaa/dotfiles](https://github.com/dennybaa/dotfiles) repository (you're already here). Install Git and perform the initial configuration:

```shell
sudo apt install git -y

# Configure Git globally
git config --global user.email "dennybaa@gmail.com"
git config --global user.name "Denis Baryshev"

# Clone the repository
cd ~ && git clone git@github.com:dennybaa/dotfiles.git

# Alternative: clone via public HTTPS
# cd ~ && git clone https://github.com/dennybaa/dotfiles.git
```

## Provision a Workstation

The provision phase installs required software and applies system configurations. This process is orchestrated by [mise](https://mise.jdx.dev) and leverages:

- **`nu/install-packages.nu`** – Handles package operations: updating APT sources, installing APT and Flatpak packages, and managing pre-built Nix profiles
- **mise** – Executes configuration hooks

### Bootstrap

1. Bootstrap installs Nix on your Debian-based system—the first step to using this repository.

    ```shell
    cd ~/dotfiles

    # Installs nix if not available
    ./bootstrap.sh

    # Runs other necessry bootstrap steps
    mise run bootstrap
    ```

    Once bootstrapped, proceed with full provisioning **using mise tasks**.

2. **Configure GitHub token for tools**

   > **Why this matters**: Configuring authentication prevents GitHub API rate limiting when package managers like Nix or mise fetch sources.

   **Recommended approach**: Create and use a fine-grained personal access token (PAT) for:
   - Generate a token at: https://github.com/settings/personal-access-tokens for only public repositories

   **Use the `setup:github-token` task**: This will prompt you for the token input and update necessary files:
   ```shell
   mise run setup:github-token
   ```

## Workstation Configuration

**Mise tasks**:

```shell
mise tasks
mise run nix --help # (for nix task details)
```

### Provision a Pre-configured System Preset

Choose the appropriate command based on your system type:

- **Console system** (terminal-only):
  ```shell
  mise provision
  ```

- **Desktop system** (includes GUI applications):
  ```shell
  mise provision:desktop
  ```

> **Note**: Use the `--update` (or `-u`) flag to refresh installed packages.

## Packages

System package configuration is defined in [packages.nu](packages.nu). Here's what it contains:

- **`AptSources`** – Files to be placed in `/etc/apt/sources.list.d/` and optional GPG key URLs for provisioning
- **`AptPackages`** and **`FlatpakPackages`** – Application bundles organized by type (base, desktop, etc.)

For example, to install both *base* and *desktop* APT package bundles:

```shell
mise packages:apt base desktop
```

> **Note**: Management of flake-based Nix profiles is intentionally not grouped under the mise `packages:nix` task.

### Nix Profile Packages

Nix profiles are defined in `nix/*/flake.nix` files. A Nix flake may have multiple outputs—for instance, `nix/code/flake.nix` contains `default` and `desktop` outputs.
When installing a Nix profile, you cannot install multiple output sets simultaneously. Choose the specific output you need:

```shell
mise nix -o desktop nix/code
```

> **Note**: If you previously installed a different flake output for a given profile, the operation will fail.
