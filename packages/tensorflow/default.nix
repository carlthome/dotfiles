{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.buildEnv {
  name = "tensorflow";
  paths = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      matplotlib
      tensorflow-bin
      tensorflow-datasets
      apache-beam
    ]))
  ];
}
