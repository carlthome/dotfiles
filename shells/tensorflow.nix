{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "tensorflow";
  packages = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      matplotlib
      tensorflow-bin
      tensorflow-datasets
      apache-beam
    ]))
  ];
  shellHook = ''
    ipython --pylab
  '';
}
