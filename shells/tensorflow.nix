{ pkgs, ... }:
pkgs.mkShell {
  name = "tensorflow";
  packages = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      matplotlib
      tensorflow
      tensorflow-datasets
    ]))
  ];
  shellHook = ''
    ipython --pylab
  '';
}
