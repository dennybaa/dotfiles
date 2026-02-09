# Workstation Setup Guide

## Prerequisites

### Configure Git
```shell
# Update with your specific settings
git config --global user.email "dennybaa@gmail.com"
git config --global user.name "Denis Baryshev"
```

### Clone Dotfiles Repository
```shell
# SSH clone (recommended)
git clone git@github.com:dennybaa/dotfiles.git

# Alternative: HTTPS clone for public access
# git clone https://github.com/dennybaa/dotfiles.git
```

## Package Installation

### System Packages (APT/Debian)
```shell
make packages-base
```

### Nix Package Manager Setup

#### 1. Authenticate with GitHub
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

#### 3. Install Nix Profiles

Use dynamic make tagrets to install nix profiles available in `nix/<profile>` directories.

```shell
make nix-desktop    # Desktop applications
make nix-tools      # Development tools
make nix-code       # Coding environment
```

## Make Commands Reference

| Command | Description |
|---------|-------------|
| **Nix Profile Management** |
| `make nix-<profile>` | Install Nix profile, eg: `make nix-tools` |
| `make nixup-<profile>` | Update Nix profile, eg: `make nixup-tools` |
| **Dotfiles Management** |
| `make stow` | Populate home directory with configuration files |
| `make stow-all` | Create all links including additional ones (systemd, etc.) |
| `make stow-clean` | Undo stow-all (systemd, etc.) |
| **Package Installation** |
| `make base` | Install base packages (including Nix tools) |
| `make all` | Alias for `make base` |
| `make desktop` | Install desktop packages (including Nix desktop) |

**Note:** The `stow-all` command creates additional links stored in the `stowes/` directory, such as for systemd services.


## Additional Details

### Nix profile managment (cli operations)

* Install a profile:
    ```shell
    cd ~/dotfiles/nix/tools && nix profile install .
    ```
* Upgrade a profile:
    ```shell
    # update flake.lock
    nix flake update --flake ./nix/tools
    nix profile upgrade nix/tools
    ```
