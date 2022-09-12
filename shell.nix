{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  python = python3.withPackages (p: with p; [
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
mkShell {
  buildInputs = [
    python
    nixpkgs-fmt
    poetry
    pre-commit
    git
    act
    ffmpeg
    libsndfile
    sox
    cudatoolkit
    cudaPackages.cudnn
  ];
  shellHook = ''
    echo "Hello $(whoami)!"
  '';
}
