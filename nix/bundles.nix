# Common shell tools for flakes
# Use: latest for unstable, pkgs for the latest stable release
{ pkgs, latest }: {

  # Bootstrap tools - minimal set of tools to start using scripts and mise tasks.
  bootstrap = [
    latest.stow
    latest.delta
    latest.gum
    latest.mise
    latest.nushell
  ];

  shellTools = [
    latest.starship
    latest.antidote
    latest.herdr
    #
    pkgs.neovim
    pkgs.fzf
    pkgs.ripgrep
    pkgs.fd
    pkgs.jq
    pkgs.tree-sitter
    pkgs.gcc
    pkgs.vimPlugins.LazyVim
  ];

  coding = [
    pkgs.lazygit
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

  desktop = [
  ];

  desktopNixGL = [
    pkgs.ghostty
  ];

  desktopCode = [
    latest.vscode
  ];

  desktopFonts = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];
}
