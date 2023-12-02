{ ... }: {
  nix-jax-mnist = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/nix-jax-mnist/archive/refs/heads/main.tar.gz";
      sha256 = "sha256:16pn51kc39c6ifvabr0mpgpvg4qnpr4j303g66jbr61ifk7ybyz5";
    });
    description = "A minimal example of using JAX with Nix";
  };
  poetry2nix-example = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/poetry2nix-example/archive/refs/heads/main.tar.gz";
      sha256 = "sha256:0qi02klhpxbknv9cy79jmvb77cyg1qn2xf6hxz4kf6b9vm8pgzgs";
    });
    description = "An example of using Poetry with Nix";
  };
}
