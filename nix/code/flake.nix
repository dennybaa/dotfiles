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

    in {
      default = pkgs.buildEnv {
        name = "code";
        paths = [
          # common
          pkgs.jq
          pkgs.yq-go
          pkgs.bat
          pkgs.just

          pkgs.nodejs_24
          pkgs.go
        ];
        pathsToLink = [ "/bin" "/share" ];
        extraOutputsToInstall = [ "out" "bin" ];
      };

      desktop = pkgs.buildEnv {
        name = "code-desktop";
        paths = [
          # all default
          self.packages.x86_64-linux.default

          # desktop tools
          latest.vscode
        ];
        pathsToLink = [ "/bin" "/share" ];
        extraOutputsToInstall = [ "out" "bin" ];
      };
    };
  };
}
