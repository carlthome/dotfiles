{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  python = python3.withPackages (p: with p; [
    #black
    #jax
    #jaxlib
    #librosa
    #matplotlib
    #mypy
    #pytorch
    #tensorflow
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
in
mkShell {
  buildInputs = [
    #pre-commit
    act
    awscli
    cargo
    ffmpeg
    git
    github-cli
    google-cloud-sdk
    jupyter
    jq
    libsndfile
    nixpkgs-fmt
    nodejs
    nodePackages.npm
    opencv
    poetry
    python
    rustup
    sox
    starship
    vim
    vscode
  ];
  shellHook = ''
    echo "Hello $(whoami)!"
  '';
}
