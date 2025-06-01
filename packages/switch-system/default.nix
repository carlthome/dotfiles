{
  pkgs,
  self,
  nix-darwin,
  ...
}:
pkgs.writeShellApplication {
  name = "switch-system";
  runtimeInputs =
    if pkgs.stdenv.hostPlatform.isLinux then
      [ pkgs.nixos-rebuild ]
    else
      [ nix-darwin.packages.${pkgs.system}.darwin-rebuild ];
  text =
    if pkgs.stdenv.hostPlatform.isLinux then
      "sudo nixos-rebuild switch --flake ${self}"
    else
      "sudo darwin-rebuild switch --flake ${self}";
}
