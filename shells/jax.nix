{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "jax";
  packages = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      matplotlib
      jax
      #jaxlib
      #jaxlib-bin
      #flax
      #optax
    ]))
  ];
  shellHook = ''
    ipython --pylab
  '';
}
