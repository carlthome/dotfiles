{ pkgs, ... }:
pkgs.mkShell {
  name = "ipython";
  packages = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      numpy
      scipy
      pandas
      matplotlib
      scikit-learn
      librosa
    ]))
  ];
  shellHook = ''
    ipython --pylab
  '';
}
