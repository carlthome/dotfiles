{ pkgs ? import <nixpkgs> { }, shellHook, ... }:
pkgs.mkShell {
  name = "home-manager";
  inherit shellHook;
  packages = with pkgs; [
    act
    cachix
    git
    home-manager
    nix-diff
    nix-info
    nixpkgs-fmt
  ];
  meta = {
    description = "Development shell for home-manager";
  };
}
