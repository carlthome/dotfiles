{ pkgs, self, ... }: {
  type = "app";
  program = (pkgs.writeScript "switch-home" ''
    set -exuo pipefail  
    home-manager switch -b backup --flake ${self}#$(whoami)@${pkgs.system}
    home-manager expire-generations '-30 days'
    home-manager packages
  '').outPath;
}
