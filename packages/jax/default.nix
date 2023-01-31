{ pkgs ? import <nixpkgs> { } }:
pkgs.buildEnv {
  name = "jax";
  paths = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      matplotlib
      jax
      jaxlib-bin
      flax
      optax
    ]))
  ];
}
