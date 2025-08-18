{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  numpyKernel = pkgs.python3.withPackages (
    ps: with ps; [
      ipykernel
      #librosa # TODO Currently broken?
      matplotlib
      numpy
      pandas
      pyarrow
      scikit-learn
      scipy
    ]
  );

  jupyterEnv = pkgs.jupyter.override {
    definitions = {
      numpy = {
        displayName = "NumPy ${pkgs.python3Packages.numpy.version}";
        language = "python";
        logo32 = null;
        logo64 = null;
        argv = [
          "${numpyKernel.interpreter}"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
      };
    };
  };

in
pkgs.buildEnv {
  name = "pylab";
  paths = [
    jupyterEnv
  ];
  meta = {
    description = "Python environment for data science exploration";
    mainProgram = "jupyter";
  };
}
