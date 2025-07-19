{
  # Can use nixos-unstable instead of the specific release
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      vscode = pkgs.vscode;     # pkg profile install .#vscode
      podman = pkgs.podman;
      devbox = pkgs.devbox;
      just = pkgs.just;
      mailspring = pkgs.mailspring;
      megasync = pkgs.megasync;
      toolbox = pkgs.toolbox;
      zoxide = pkgs.zoxide;
      keepassxc = pkgs.keepassxc;
      syncthing = pkgs.syncthing;
    };
  };
}

