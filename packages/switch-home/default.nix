{
  pkgs,
  self,
  home-manager,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
pkgs.writeShellApplication {
  name = "switch-home";
  runtimeInputs = [ home-manager.packages.${system}.home-manager ];
  text = "home-manager switch --flake ${self}";
}
