{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.python3Packages.buildPythonApplication {
  pname = "mnist";
  version = "0.1.0";
  src = ./.;
  format = "pyproject";

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
    pytestCheckHook
  ];

  importChecks = [ "mnist" ];

  propagatedBuildInputs = with pkgs.python3Packages; [
    fire
    torch
    torchaudio-bin
    torchmetrics
    torchvision
    pytorch-lightning
    onnx
    onnxruntime
  ];
}
