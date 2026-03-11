{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, unstable }: {
    packages.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      latest = import unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      fonts = [
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.fira-code
      ];

      fontsConf = pkgs.makeFontsConf { fontDirectories = fonts; };

    in {
      default = pkgs.buildEnv {
        name = "code";
        paths = [
          # common
          pkgs.jq
          pkgs.yq-go
          pkgs.just

          pkgs.nodejs_24
          pkgs.go
        ];
        pathsToLink = [ "/bin" "/share" ];
        extraOutputsToInstall = [ "out" "bin" ];
      };

      desktop = pkgs.symlinkJoin {
        name = "code-desktop";
        paths = [
          self.packages.x86_64-linux.default
          latest.vscode
        ] ++ fonts;

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
