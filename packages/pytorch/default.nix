{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.buildEnv {
  name = "ipython";
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
