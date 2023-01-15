{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "home-manager";
  packages = with pkgs; [
    home-manager
    git
    act
    cachix
    nix-diff
    nix-info
    nixfmt
    nixpkgs-fmt
    vim
  ];
  shellHook = ''
    home-manager generations
  '';
}
