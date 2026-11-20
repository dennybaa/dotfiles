# Obsidian with a CLI preflight: start the app if the CLI cannot answer yet,
# then run the command once. Without it a closed app makes every command fail
# with the socket error (rc 1) instead of doing its job.
{ pkgs, base }:
let
  real = "${base}/bin/obsidian"; # GUI; also what brings the app up
  realCli = "${base}/bin/obsidian-cli"; # socket-only, 0 ms

  # Both names relay commands through the socket-only client: same answer, no
  # Electron boot. `real` is only used to start the app.
  wrap =
    name: gui:
    pkgs.writeShellScriptBin name ''
      set -uo pipefail
      gui=${pkgs.lib.escapeShellArg gui}
      cli=${pkgs.lib.escapeShellArg realCli}

      # No args = open the GUI, never preflight.
      [ "$#" -eq 0 ] && exec "$gui"

      # `version` answers only while the app is up: rc 1 means "no socket yet".
      if ! "$cli" version >/dev/null 2>&1; then
        setsid ${real} >/dev/null 2>&1 </dev/null &
      fi

      ready=
      for _ in $(seq 40); do
        "$cli" version >/dev/null 2>&1 && { ready=1; break; }
        sleep 0.25
      done
      if [ -z "$ready" ]; then
        echo "obsidian: app did not answer within 10s" >&2
        exit 1
      fi

      exec "$cli" "$@"
    '';
in
# symlinkJoin, not buildEnv: buildEnv ships the base's /share as one dir
# symlink, and the profile's merge cannot add into it, so other packages' files
# in that dir are dropped. This links per file, so one package carries both.
pkgs.symlinkJoin {
  name = "obsidian-${base.version}";
  # First path wins a duplicate name: the shims must precede the base.
  paths = [
    (wrap "obsidian" real)
    (wrap "obsidian-cli" realCli)
    base
  ];
}
