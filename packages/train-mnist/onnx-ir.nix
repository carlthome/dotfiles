{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "onnx-ir";
  version = "0.1.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "onnx";
    repo = "ir-py";
    rev = "v${version}";
    hash = "sha256-vY682j07Hvqb30ihQNZu2QUOsLwQx2J5hpRoTOSJFNw=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    ml-dtypes
    numpy
    onnx
    typing-extensions
  ];

  pythonImportsCheck = [
    "onnx_ir"
  ];

  meta = {
    description = "Efficient in-memory representation for ONNX, in Python";
    homepage = "https://github.com/onnx/ir-py";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
