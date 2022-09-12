{ pkgs, ... }: {
  python = pkgs.python3.withPackages (ps: with ps; [
    black
    jax
    jaxlib
    librosa
    matplotlib
    mypy
    pytorch
    tensorflow
    flake8
    ipython
    isort
    numpy
    opencv
    pandas
    pip
    scipy
    setuptools
  ]);
}
