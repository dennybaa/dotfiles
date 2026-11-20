# Packages not declared in bundles.nix: external flake inputs and local wrappers.
# Each key needs a `++ (extra.<bundle> or [ ])` hook in bundles.nix.
{
  pkgs,
  latest,
  inputs,
}:
let
  # obsidian + CLI preflight (see ./desktop/obsidian.nix)
  obsidianWrapped = import ./desktop/obsidian.nix {
    inherit pkgs;
    base = latest.obsidian;
  };
in
{
  cliTools = [
    # workmux: parallel development in tmux with git worktrees.
    # inputs.workmux.packages.${latest.stdenv.hostPlatform.system}.default
  ];

  # Carries bin/ and share/ itself, so the base is not listed here.
  codingDesktop = [ obsidianWrapped ];
}
