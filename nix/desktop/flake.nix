{
  inputs = {
    release.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nixGL provides the hardware graphics wrapper on non-NixOS hosts
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs =
    {
      self,
      release,
      unstable,
      nixgl,
    }:
    {
      packages.x86_64-linux =
        let
          pkgs = import release {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };

          latest = import unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = [ nixgl.overlay ];
          };

          # Include bundles definitions
          bundle = import ../bundles.nix { inherit pkgs latest; };

          # Fonts config
          fontsConf = pkgs.makeFontsConf { fontDirectories = bundle.desktopFonts; };

          # Wraped desktopNixGL (use nixGLIntel: Mesa OpenGL implementation (intel, amd, nouveau, ...)
          wrapWithNixGL =
            pkg:
            latest.symlinkJoin {
              name = "${pkg.name}-nixgl";
              paths = [ pkg ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                # 1. Create a nixGL wrapper
                for bin in $(cd ${pkg}/bin && find . -type f -executable); do
                  rm -f $out/bin/$bin
                  makeWrapper ${latest.nixgl.nixGLIntel}/bin/nixGLIntel $out/bin/$bin \
                    --add-flags "${pkg}/bin/$bin" \
                    --set FONTCONFIG_FILE "${fontsConf}" \
                    --inherit-argv0
                done

                # 2. Patch .desktop files
                if [ -d "${pkg}/share/applications" ]; then
                  rm -rf $out/share/applications
                  mkdir -p $out/share/applications

                  for desktop in ${pkg}/share/applications/*.desktop; do
                    [ -e "$desktop" ] || continue
                    base=$(basename "$desktop")
                    cp "$desktop" $out/share/applications/"$base"
                    chmod +w $out/share/applications/"$base"

                    # Extract the executable name from the original Exec= line (ignoring arguments)
                    orig_cmd=$(grep -E '^Exec=' "$desktop" | head -n1 | cut -d' ' -f1 | sed 's/^Exec=//')
                    new_cmd="$out/bin/$(basename "$orig_cmd")"

                    # Replace only the command part, preserving all arguments
                    substituteInPlace $out/share/applications/"$base" \
                      --replace "Exec=$orig_cmd" "Exec=$new_cmd"
                  done
                fi
              '';
            };

          desktopNixGL = builtins.map wrapWithNixGL bundle.desktopNixGL;
          hasVscode = builtins.elem latest.vscode bundle.codingDesktop;
        in
        {
          default = pkgs.symlinkJoin {
            name = "default";
            paths =
              bundle.bootstrap
              ++ bundle.shellTools
              ++ bundle.netUtils
              ++ bundle.podman
              ++ bundle.kubernetes
              ++ bundle.desktop
              ++ bundle.desktopFonts
              ++ bundle.coding
              ++ bundle.codingDesktop
              ++ bundle.virt
              ++ desktopNixGL;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            postBuild = pkgs.lib.optionalString hasVscode ''
              # Specify fontConfig if latest.vscode is bundled in codingDesktop
              rm $out/bin/code
              makeWrapper ${latest.vscode}/bin/code $out/bin/code \
                --set FONTCONFIG_FILE "${fontsConf}"
            '';
          };
        };
    };
}
