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
        name = "cli-tools";
        paths = [
          # cli
          pkgs.jq
          pkgs.yq-go
          pkgs.zoxide
          pkgs.bat
          pkgs.stow

          # langs
          latest.devenv
          latest.nushell
          latest.crossplane-cli
          latest.cue
          latest.kcl
          latest.kcl-language-server

          # containers
          pkgs.toolbox
          pkgs.podman
          pkgs.docker-client
          pkgs.docker-credential-helpers
          pkgs.docker-compose
          pkgs.docker-buildx
          pkgs.kind
          pkgs.k9s

          # devops
          pkgs.gh
          pkgs.just
          pkgs.argocd
          pkgs.kubectl
          pkgs.helmfile
          pkgs.sops
          # Customize google cloud sdk
          (pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
            gke-gcloud-auth-plugin
          ]))
          latest.kubernetes-helm
        ];
        pathsToLink = [ "/bin" "/share" ];
        extraOutputsToInstall = [ "out" "bin" ];
      };
    };
  };
}
