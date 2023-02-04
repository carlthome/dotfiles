{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.buildEnv {
  name = "sklearn";
  paths = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      jupyter
      librosa
      matplotlib
      numpy
      pandas
      scikit-learn
      scipy
      apache-beam
    ]))
  ];
}
