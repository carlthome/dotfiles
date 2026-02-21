{ pkgs, ... }:
pkgs.python3Packages.buildPythonApplication {
  pname = "ping-home";
  version = "0.1.0";
  pyproject = true;

  src = ./app;

  build-system = [ pkgs.python3Packages.setuptools ];

  dependencies = with pkgs.python3Packages; [
    flask
    gunicorn
    requests
    pysocks
  ];

  nativeCheckInputs = [ pkgs.python3Packages.pytest ];
}
