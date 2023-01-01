{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "ipython";
  packages = [
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
  shellHook = ''
    ipython --pylab
  '';
}
