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
        name = "cli-tools";
        paths = [
          # cli
          pkgs.jq
          pkgs.yq-go
          pkgs.zoxide

          # containers
          pkgs.toolbox
          pkgs.podman
          pkgs.k3d

          # devops
          pkgs.gh
          pkgs.just
          pkgs.argocd
          pkgs.kubectl
          pkgs.kubernetes-helm
          pkgs.helmfile
          pkgs.sops
          pkgs.google-cloud-sdk

          # latest versions
          latest.devenv
          latest.nushell
          latest.crossplane-cli
          latest.cue
          latest.kcl
          latest.kcl-language-server
        ];
        pathsToLink = [ "/bin" "/share" ];
        extraOutputsToInstall = [ "out" "bin" ];
      };
    };
  };
}
