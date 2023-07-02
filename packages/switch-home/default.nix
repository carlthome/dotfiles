{ pkgs, self, home-manager, ... }: pkgs.writeScriptBin "switch-home" ''
  set -exuo pipefail
  ${home-manager}/bin/home-manager expire-generations '-30 days'
  ${home-manager}/bin/home-manager switch --flake ${self}
  ${home-manager}/bin/home-manager packages
''
