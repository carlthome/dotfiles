{
  lib,
  python3Packages,
  fetchFromGitHub,
  git,
  onnx-ir,
}:

python3Packages.buildPythonPackage rec {
  pname = "onnxscript";
  version = "0.5.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "onnxscript";
    rev = "v${version}";
    hash = "sha256-vMxjB0FhONzLE2Duje5//T6hWXTGTXUPYRNLAWQpZEk=";
  };

  build-system = with python3Packages; [
    setuptools
    git
  ];

  dependencies = with python3Packages; [
    ml-dtypes
    numpy
    onnx
    onnx-ir
    packaging
    typing-extensions
  ];

  pythonImportsCheck = [
    "onnxscript"
  ];

  meta = {
    description = "ONNX Script enables developers to naturally author ONNX functions and models using a subset of Python";
    homepage = "https://github.com/microsoft/onnxscript";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ carlthome ];
  };
}
