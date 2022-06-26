{ pkgs ? import <nixpkgs> {} }:
  let
    python = pkgs.python3.withPackages (p: with p; [
      pip
      setuptools
      ipython
      black
      mypy
      flake8
      isort
      numpy
      scipy
      pandas
      matplotlib
      librosa
      pytorchWithCuda
      tensorflowWithCuda
    ]);
  in
  pkgs.mkShell {
    buildInputs = [
      python
      pkgs.git
      pkgs.act
      pkgs.ffmpeg
      pkgs.libsndfile
      pkgs.sox
      pkgs.cudatoolkit
      pkgs.cudaPackages.cudnn
    ];
    shellHook = ''
      PYTHONPATH=${python}/${python.sitePackages}
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.cudaPackages_10_1.cudatoolkit}/lib:${pkgs.cudaPackages_10_1.cudnn}/lib:${pkgs.cudaPackages_10_1.cudatoolkit.lib}/lib
      alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
      export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
      unset SOURCE_DATE_EPOCH
    '';
  }
