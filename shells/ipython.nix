{ pkgs, ... }:
pkgs.mkShell
{
  name = "ipython";
  nativeBuildInputs = [
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
