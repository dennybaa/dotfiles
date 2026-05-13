{
  inputs = {
    release.url = "github:NixOS/nixpkgs/nixos-25.11";
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

      # Fonts config
      fontsConf = pkgs.makeFontsConf { fontDirectories = bundle.desktopFonts; };

    in {
      default = pkgs.symlinkJoin {
        name = "default";
        paths = bundle.bootstrap
        ++ bundle.shellTools
        ++ bundle.netUtils
        ++ bundle.podman
        ++ bundle.kubernetes
        ++ bundle.desktopCode
        ++ bundle.desktopFonts
        ;

        nativeBuildInputs = [ pkgs.makeWrapper ];

        # Specify the fontconfig
        postBuild = ''
          rm $out/bin/code
          makeWrapper ${latest.vscode}/bin/code $out/bin/code \
            --set FONTCONFIG_FILE "${fontsConf}"
        '';
      };
    };
  };
}
