{
  lib,
  python3Packages,
  fetchFromGitHub,
  git,
  onnx-ir,
}:

python3Packages.buildPythonPackage rec {
  pname = "onnxscript";
  version = "0.7.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "onnxscript";
    rev = "v${version}";
    hash = "sha256-l6Nsnbg7LG/0Z9y1EX5BPP3sFdY/EZwRFFHOrP4mwdw=";
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
