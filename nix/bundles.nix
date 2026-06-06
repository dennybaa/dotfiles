# Common shell tools for flakes
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
    latest.fzf
    pkgs.jq
    pkgs.neovim
    pkgs.tree-sitter
    pkgs.vimPlugins.LazyVim
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

  desktopCode = [
    latest.nixd
    latest.vscode
  ];

  desktopFonts = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];
}
