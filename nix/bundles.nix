# Common shell tools for flakes
# Use: latest for unstable, pkgs for the latest stable release
{
  pkgs,
  latest,
  extra ? { },
}:
{

  # Bootstrap tools - minimal set of tools to start using scripts and mise tasks.
  bootstrap = [
    latest.stow
    latest.delta
    latest.gum
    # Currently handling mise via official script installer
    # latest.mise
    latest.nushell
    pkgs.jq
  ];

  cliTools = [
    # temrinal tools
    pkgs.tmux
    pkgs.chafa
    pkgs.glow
    latest.starship
    latest.antidote
    latest.herdr

    # vim
    pkgs.neovim
    pkgs.tree-sitter
    pkgs.vimPlugins.LazyVim

    # utils
    latest.yazi
    latest.lazygit
    latest.bat
    pkgs.zoxide
    pkgs.fzf
    pkgs.ripgrep
    pkgs.fd
    pkgs.wl-clipboard
  ]
  # Add extra cli tools loaded from separate flakes
  ++ (extra.cliTools or [ ]);

  coding = [
    pkgs.jq
    pkgs.yq
    # nvim base (gcc can be required for tree-sitter)
    pkgs.gcc
    latest.pi-coding-agent
  ];

  codingDesktop = [
    # nix
    pkgs.nixfmt
    pkgs.nixd
    pkgs.statix
  ];

  netUtils = [
    latest.grpcurl
    latest.ptcpdump
  ];

  podman = [
    pkgs.podman
    pkgs.docker-client
    pkgs.docker-credential-helpers
    pkgs.docker-compose
    pkgs.docker-buildx
  ];

  virt = [
    pkgs.virt-manager
    pkgs.passt
    pkgs.libvirt
    pkgs.virtiofsd
  ];

  kubernetes = [
    pkgs.k9s
    pkgs.sops
  ];

  # GPU userspace (mesa vendors, DRI drivers) for nix GUI apps. nixpkgs libglvnd
  # looks for it in /run/opengl-driver, so that path is linked to this profile
  # by `mise run setup:opengl-driver`.
  gpuDrivers = [
    latest.mesa
  ];

  desktop = [
  ];

  # Desktop apps that need the shared fontconfig wrapper (see desktop.nix).
  desktopWrapped = [
    latest.ghostty
  ];

  desktopFonts = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];
}
