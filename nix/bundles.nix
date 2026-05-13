# Common shell tools for flakes
{ pkgs, latest }: {

  # Bootstrap tools - minimal set of tools to start using scripts and mise tasks.
  bootstrap = [
    latest.chezmoi
    latest.stow
    latest.delta
    latest.gum
    latest.mise
    latest.nushell
    latest.jq
  ];

  shellTools = [
    latest.neovim
    latest.starship
    latest.antidote
    latest.fzf
    latest.vimPlugins.LazyVim
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

  kubernetes = [
    pkgs.k9s
    pkgs.sops
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
