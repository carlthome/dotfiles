{
  pkgs ? import <nixpkgs> { },
  shellHook ? "",
  buildInputs ? [ ],
  ...
}:
pkgs.mkShell {
  name = "home-manager";
  inherit buildInputs;
  inherit shellHook;
  packages = with pkgs; [
    act
    nix
    git
    home-manager
    nix-diff
    nix-info
  ];
}
