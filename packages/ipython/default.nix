{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.buildEnv {
  name = "ipython";
  paths = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      # TODO Jupyter is currently broken.
      #jupyter
      librosa
      matplotlib
      numpy
      pandas
      scikit-learn
      scipy
    ]))
  ];
  meta = {
    description = "Python environment for data science exploration";
  };
}
