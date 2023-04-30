{ pkgs, self, home-manager, ... }: {
  type = "app";
  program = (pkgs.writeScript "switch-home" ''
    set -exuo pipefail
    ${home-manager}/bin/home-manager expire-generations '-30 days'
    ${home-manager}/bin/home-manager switch --flake ${self}
    ${home-manager}/bin/home-manager packages
  '').outPath;
}
