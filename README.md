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

Bootstrap installs Nix on your Debian-based system—the first step to using this repository.

```shell
cd ~/dotfiles
./bootstrap.sh
```

Once bootstrapped, proceed with the full provisioning **using mise tasks**.

<!-- #### 1. Authenticate with GitHub
```shell
# Login to GitHub CLI
gh auth login
```

#### 2. Configure Nix Authentication
```shell
# Create nix configuration directory and set GitHub token
mkdir -p ~/.config/nix
echo "access-tokens = github.com=$(gh auth token)" >> ~/.config/nix/nix.conf
chmod 600 ~/.config/nix/nix.conf
```

**Notes**:
- Ensure you have proper permissions for GitHub repository access
- The `gh auth token` command automatically retrieves your current authentication token
- Keep your nix.conf secure as it contains authentication tokens
 -->

## Workstation Configuration

**Mise tasks**:

| Task                  | Description |
|-----------------------|-------------|
| `nix`                 | Provision (install/update) Nix packages |
| `nix:profiles`        | List Nix profiles |
| `nix:profiles:ls`     | List installed Nix profiles |
| `packages`            | Provision system packages (APT, Flatpak) |
| `packages:apt`        | Provision APT packages |
| `packages:flatpak`    | Provision Flatpak packages |
| `provision`           | Provision default workstation (console) |
| `provision:desktop`   | Provision default workstation (desktop) |

For detailed information about a specific command, use the `--help` flag. For example:
```shell
mise nix --help
```

This should output something similar to:

```
Usage: nix [-u --update] [-o --output <output>] <profile>

Arguments:
  <profile>  Specify which nix profile to (profiles under nix/*)

Flags:
  -u --update           Update nix profile (forces update even if flake.nix
                        changes are not tracked)
  -o --output <output>  Specify flake package output (see the corresponding
                        flake.nix aka desktop/cloud etc)
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

<!-- ## Make Commands Reference

| Command | Description |
|---------|-------------|
| **Nix Profile Management** |
| **Dotfiles Management** |
| `make stow` | Populate home directory with configuration files |
| `make stow-all` | Create all links including additional ones (systemd, etc.) |
| `make stow-clean` | Undo stow-all (systemd, etc.) |

**Note:** The `stow-all` command creates additional links stored in the `stowes/` directory, such as for systemd services. -->
