{ pkgs, self, ... }: {
  type = "app";
  program = (pkgs.writeScript "switch-home" ''
    set -exuo pipefail  
    home-manager switch --flake ${self}
    home-manager expire-generations '-30 days'
    home-manager packages
  '').outPath;
}
