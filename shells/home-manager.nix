{ pkgs, ... }:
pkgs.mkShell
{
  name = "home-manager";
  nativeBuildInputs = with pkgs; [
    nixpkgs-fmt
    nixfmt
    nix-info
    cachix
    act
    vim
    git
    home-manager
  ];
  shellHook = ''
    home-manager --version
  '';
}
