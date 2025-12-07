{
  pkgs ? import <nixpkgs> { },
  ...
}:

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

  propagatedBuildInputs =
    with pkgs.python3Packages;
    let
      onnx-ir = pkgs.callPackage ./onnx-ir.nix { };
      onnxscript = pkgs.callPackage ./onnxscript.nix { inherit onnx-ir; };
    in
    [
      fire
      torch
      torchaudio
      torchmetrics
      torchvision
      pytorch-lightning
      onnx
      onnxscript
      onnxruntime
      gradio
      fastapi
    ];
}
