{
  inputs = {
    release.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # workmux: parallel development in tmux with git worktrees
    # workmux = {
    #   url = "github:raine/workmux";
    #   inputs.nixpkgs.follows = "unstable";
    # };
  };

  outputs =
    inputs@{
      self,
      release,
      unstable,
      ...
    }:
    let
      pkgs = import release {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      latest = import unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      # Extra packages sourced from external flake inputs.
      # The whole input set is forwarded so new sources do not need to be
      # named here.
      extra = import ../extra.nix { inherit pkgs latest inputs; };

      # Include bundles definitions
      bundle = import ../bundles.nix { inherit pkgs latest extra; };
    in
    {
      packages.x86_64-linux.default = pkgs.symlinkJoin {
        name = "default";
        paths =
          bundle.bootstrap
          ++ bundle.cliTools
          ++ bundle.netUtils
          ++ bundle.podman
          ++ bundle.kubernetes
          ++ bundle.desktop
          ++ bundle.gpuDrivers
          ++ bundle.desktopFonts
          ++ bundle.coding
          ++ bundle.codingDesktop
          ++ bundle.virt;
      };
    };
}
