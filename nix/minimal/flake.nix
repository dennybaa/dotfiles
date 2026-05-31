{
  inputs = {
    release.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, release, unstable }: {
    packages.x86_64-linux = let
      pkgs = import release {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      latest = import unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      # Include bundles definitions
      bundle = import ../bundles.nix { inherit pkgs latest; };

    in {
      default = pkgs.symlinkJoin {
        name = "default";
        paths = bundle.bootstrap
        ++ bundle.shellTools
        ++ bundle.netUtils
        ++ bundle.podman
        ;

        nativeBuildInputs = [ pkgs.makeWrapper ];
      };
    };
  };
}
