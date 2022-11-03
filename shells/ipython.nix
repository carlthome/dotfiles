{ pkgs, ... }:
pkgs.mkShell
{
  name = "ipython";
  nativeBuildInputs = with pkgs; [
    python3Packages.ipython
  ];


  shellHook = ''
    ipython
  '';
}
