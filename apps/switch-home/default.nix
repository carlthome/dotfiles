{ pkgs, self, ... }: {
  type = "app";
  program = (pkgs.writeScript "switch-home" ''
    set -exuo pipefail  
    home-manager switch -b backup --flake .
    home-manager expire-generations '-30 days'
    home-manager packages
  '').outPath;
}
