{ pkgs, ... }: {
  type = "app";
  program = (pkgs.writeScript "switch-home" ''
    set -exuo pipefail
    home-manager switch --flake .#$(whoami)@${pkgs.system}
    home-manager expire-generations '-30 days'
    nix store optimise
    home-manager packages
  '').outPath;
}
