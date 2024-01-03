{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.python3Packages.buildPythonApplication {
  pname = "stable-diffusion";
  version = "0.1.0-dev0";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "carlthome";
    repo = "stable-diffusion";
    rev = "33e258e2aba132d5314abb3580ebe4c97f3aacc8";
    hash = "sha256-NJBajRupDJJupwFoY6zFgodel4fKNXqZgzF7vKC5seE=";
  };

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    setuptools_scm
  ];

  importChecks = [ "main" ];

  propagatedBuildInputs = with pkgs.python3Packages; [
    accelerate
    diffusers
    safetensors
    torch
    transformers
  ];
}
