{ pkgs, ... }: {
  type = "app";
  program = (pkgs.writeScript "update-home" ''
    set -exuo pipefail
    home-manager switch --flake .#$(whoami)@${pkgs.system}
    home-manager expire-generations '-30 days'
    home-manager packages
  '').outPath;
}
