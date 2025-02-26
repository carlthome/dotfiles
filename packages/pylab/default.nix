{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.buildEnv {
  name = "pylab";
  paths = [
    (pkgs.python3.withPackages (
      ps: with ps; [
        ipython
        ipdb
        jupyter
        librosa
        matplotlib
        numpy
        pandas
        scikit-learn
        scipy
        pyarrow
      ]
    ))
  ];
  meta = {
    description = "Python environment for data science exploration";
    mainProgram = "jupyter";
  };
}
