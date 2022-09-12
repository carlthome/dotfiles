{ pkgs, ... }: {
  env = pkgs.python3.withPackages (ps:
    with ps; [
      jax
      jaxlib
      librosa
      matplotlib
      mypy
      pytorch
      flake8
      ipython
      isort
      numpy
      pandas
      pip
      scipy
      setuptools
    ]);
}
