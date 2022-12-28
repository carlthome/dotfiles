{ pkgs, ... }:
pkgs.mkShell {
  name = "home-manager";
  packages = with pkgs; [
    home-manager
    nixfmt
    nix-info
    nix-diff
    nixpkgs-fmt
    cachix
    git
    act
    vim
  ];
  shellHook = ''
    home-manager help
  '';
}
