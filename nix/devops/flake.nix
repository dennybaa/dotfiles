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
        name = "devops";
        paths = [
          # common container tools
          pkgs.podman
          pkgs.docker-client
          pkgs.docker-credential-helpers
          pkgs.docker-compose
          pkgs.docker-buildx
          pkgs.kind
          pkgs.k9s

          # other
          pkgs.sops
        ];
        pathsToLink = [ "/bin" "/share" ];
        extraOutputsToInstall = [ "out" "bin" ];
      };

      cloud = pkgs.buildEnv {
        name = "devops-cloud";
        paths = [
          # all default
          self.packages.x86_64-linux.default

          (pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
            gke-gcloud-auth-plugin
          ]))
        ];
        pathsToLink = [ "/bin" "/share" ];
        extraOutputsToInstall = [ "out" "bin" ];
      };
    };
  };
}
