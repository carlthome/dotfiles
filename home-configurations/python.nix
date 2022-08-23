{ pkgs, ... }: {
  env = pkgs.python3.withPackages (ps:
    with ps; [
      jax
      jaxlib
      librosa
      matplotlib
      pytorch
      flake8
      ipython
      numpy
      pandas
      pip
      scipy
      setuptools
    ]);
}
