{ pkgs ? import <nixpkgs> { } }:
pkgs.buildEnv {
  name = "pytorch";
  paths = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      matplotlib
      torch-bin
      torchaudio-bin
      torchvision-bin
      huggingface-hub
      transformers
      datasets
    ]))
  ];
}
