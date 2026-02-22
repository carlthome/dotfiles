{ pkgs, ... }:
pkgs.python3Packages.buildPythonApplication {
  pname = "ping-home";
  version = "0.1.0";
  pyproject = true;

  src = ./app;

  build-system = [ pkgs.python3Packages.setuptools ];

  dependencies = with pkgs.python3Packages; [
    fastapi
    uvicorn
    requests
    pysocks
    prometheus-client
  ];

  nativeCheckInputs = with pkgs.python3Packages; [
    httpx
    pytest
    pkgs.ruff
  ];

  checkPhase = ''
    ruff format --check .
    pytest
  '';
}
