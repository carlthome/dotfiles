{ pkgs, ... }:
pkgs.mkShell {
  name = "home-manager";
  nativeBuildInputs = with pkgs; [
    home-manager
    nixfmt
    nix-info
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
