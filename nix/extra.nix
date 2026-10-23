# Extra packages sourced from external flake inputs rather than nixpkgs.
# Returns a bundle-shaped attrset consumed by bundles.nix via its `extra` arg.
{
  pkgs,
  latest,
  inputs,
}:
{
  cliTools = [
    # workmux: parallel development in tmux with git worktrees.
    # inputs.workmux.packages.${latest.stdenv.hostPlatform.system}.default
  ];
}
