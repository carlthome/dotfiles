{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.python311Packages.buildPythonApplication {
  pname = "mnist";
  version = "0.1.0";
  src = ./.;
  format = "pyproject";

  nativeBuildInputs = with pkgs.python311Packages; [
    setuptools
    wheel
    pytestCheckHook
  ];

  importChecks = [ "mnist" ];

  propagatedBuildInputs = with pkgs.python311Packages; [
    fire
    torch
    torchaudio
    torchmetrics
    torchvision
    pytorch-lightning
    onnx
    onnxruntime
    gradio
    fastapi
  ];
}
