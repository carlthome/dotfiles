{ pkgs, self, home-manager, ... }: pkgs.writeShellApplication {
  name = "switch-home";
  runtimeInputs = [ home-manager ];
  text = ''
    set -exuo pipefail
    home-manager expire-generations '-30 days'
    home-manager switch --flake ${self}
    home-manager packages
  '';
}
