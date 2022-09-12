{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  python = python3.withPackages (p: with p; [
    pip
    setuptools
    ipython
    #black
    #mypy
    flake8
    isort
    numpy
    scipy
    pandas
    #matplotlib
    #librosa
    #pytorch
    #tensorflow
    #jax
    #jaxlib
  ]);
in
mkShell {
  buildInputs = [
    rustup
    cargo
    starship
    python
    nixpkgs-fmt
    poetry
    #pre-commit
    git
    act
    ffmpeg
    libsndfile
    sox
    google-cloud-sdk
    github-cli
  ];
  shellHook = ''
    echo "Hello $(whoami)!"
  '';
}
