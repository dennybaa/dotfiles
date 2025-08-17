{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
          pkgs.nodejs_24
        ];
        pathsToLink = [ "/bin" "/share" ];
        extraOutputsToInstall = [ "out" "bin" ];
      };
    };
  };
}
