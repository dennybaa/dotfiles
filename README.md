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

#### 3. Install Nix Profiles
```shell
# Install various profile groups
make nix-desktop    # Desktop applications
make nix-tools      # Development tools
make nix-code       # Coding environment
# ... and others as needed
```

## Profile Management

### Install Specific Profile
```shell
# Install tools profile
cd ~/dotfiles/nix/tools && nix profile install .
```

### Upgrade Profiles
```shell
# Upgrade tools profile
nix profile upgrade nix/tools
```

## Make commands

### Stowing links (dotfiles)

To populate home directory with configuration files form this repository run the bellow commands:

```shell
make stow

# also creates addition links, such as for systemd (stored in stowes/ directory)
make stow-all
```

### Install packages

- Install base packages including (nix/tools): `make base` (`make all`)
- Install desktop packages including (nix/desktop): `make desktop`

## Notes
- Ensure you have proper permissions for GitHub repository access
- The `gh auth token` command automatically retrieves your current authentication token
- Keep your nix.conf secure as it contains authentication tokens
