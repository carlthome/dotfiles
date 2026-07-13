{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "onnx-ir";
  version = "0.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "onnx";
    repo = "ir-py";
    rev = "v${version}";
    hash = "sha256-vdo8BiE7m9Qr3JktgcPGDZfykjcf/VYY39tfhtzOrpA=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    ml-dtypes
    numpy
    onnx
    sympy
    typing-extensions
  ];

  pythonImportsCheck = [
    "onnx_ir"
  ];

  meta = {
    description = "Efficient in-memory representation for ONNX, in Python";
    homepage = "https://github.com/onnx/ir-py";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
