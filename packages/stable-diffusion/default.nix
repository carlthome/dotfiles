{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.python3Packages.buildPythonApplication {
  pname = "stable-diffusion";
  version = "0.1.0-dev0";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "carlthome";
    repo = "stable-diffusion";
    rev = "ac5a74677c6bc1a631aa844e8e826e8a20763ffd";
    hash = "sha256-amgWyAtR8JLrSMWDhsX4cv0sMrvyBW+vm4AzahjH+Ts=";
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
