{
  pkgs,
  self,
  nix-darwin,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
pkgs.writeShellApplication {
  name = "switch-system";
  runtimeInputs =
    if pkgs.stdenv.hostPlatform.isLinux then
      [ pkgs.nixos-rebuild ]
    else
      [ nix-darwin.packages.${system}.darwin-rebuild ];
  text =
    if pkgs.stdenv.hostPlatform.isLinux then
      "sudo nixos-rebuild switch --flake ${self}"
    else
      "sudo darwin-rebuild switch --flake ${self}";
}
