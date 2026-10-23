# Desktop bundle assembly.
#
# Kept out of flake.nix so the flake stays focused on inputs and wiring.
# Everything it needs is passed in explicitly.
{
  pkgs,
  latest,
  bundle,
}:
let
  # Fonts config
  fontsConf = pkgs.makeFontsConf { fontDirectories = bundle.desktopFonts; };

  # Wrapped desktop apps: shared fontconfig so GTK apps see the nix fonts.
  # GL/EGL is resolved by the loader via /run/opengl-driver (see bundles.gpuDrivers),
  # so nothing has to be exported into the session environment.
  wrapForDesktop =
    pkg:
    latest.symlinkJoin {
      name = "${pkg.name}-desktop";
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        # 1. Wrap binaries with the shared fontconfig
        for bin in $(cd ${pkg}/bin && find . -type f -executable); do
          rm -f $out/bin/$bin
          makeWrapper "${pkg}/bin/$bin" $out/bin/$bin \
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

  desktopWrapped = builtins.map wrapForDesktop bundle.desktopWrapped;
  hasVscode = builtins.elem latest.vscode bundle.codingDesktop;
in
pkgs.symlinkJoin {
  name = "default";
  paths =
    bundle.bootstrap
    ++ bundle.cliTools
    ++ bundle.netUtils
    ++ bundle.podman
    ++ bundle.kubernetes
    ++ bundle.desktop
    ++ bundle.gpuDrivers
    ++ bundle.desktopFonts
    ++ bundle.coding
    ++ bundle.codingDesktop
    ++ bundle.virt
    ++ desktopWrapped;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  postBuild = pkgs.lib.optionalString hasVscode ''
    # Specify fontConfig if latest.vscode is bundled in codingDesktop
    rm $out/bin/code
    makeWrapper ${latest.vscode}/bin/code $out/bin/code \
      --set FONTCONFIG_FILE "${fontsConf}"
  '';
}
