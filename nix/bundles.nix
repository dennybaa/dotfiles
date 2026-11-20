# Package lists shared by the flakes: pkgs. by default, latest. only where stable lacks a package or lags it.
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
    latest.mise
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

    # utils
    latest.yazi
    latest.lazygit
    pkgs.bat
    pkgs.zoxide
    pkgs.fzf
    pkgs.ripgrep
    pkgs.fd
    pkgs.wl-clipboard
    pkgs.rclone
  ]
  # Add extra cli tools loaded from separate flakes
  ++ (extra.cliTools or [ ]);

  coding = [
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

    # Tools
    latest.mdfried
    latest.html2text
    latest.readability-cli

    # AI tools
    latest.graphify
  ]
  # Add extra desktop tools loaded from extra.nix
  ++ (extra.codingDesktop or [ ]);

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
    pkgs.lazydocker
  ];

  virt = [
    pkgs.virt-manager
    pkgs.passt
    pkgs.libvirt
    pkgs.virtiofsd
  ];

  kubernetes = [
    pkgs.sops
  ];

  # GPU userspace (mesa vendors, DRI drivers) for nix GUI apps. nixpkgs libglvnd
  # looks for it in /run/opengl-driver, which is linked to this profile when
  # the desktop composition is stowed (mise-tasks/hooks/stow/desktop/_bundle/opengl-driver).
  gpuDrivers = [
    latest.mesa
  ];

  desktop = [
    latest.ghostty
  ];

  desktopFonts = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];
}
