{ ... }: {
  nix-jax-mnist = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/nix-jax-mnist/archive/refs/heads/main.tar.gz";
      sha256 = "16pn51kc39c6ifvabr0mpgpvg4qnpr4j303g66jbr61ifk7ybyz5";
    });
    description = "A fully-functional example of using JAX to train a MNIST classifier with Nix";
  };
  poetry2nix-example = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/poetry2nix-example/archive/refs/heads/main.tar.gz";
      sha256 = "0qi02klhpxbknv9cy79jmvb77cyg1qn2xf6hxz4kf6b9vm8pgzgs";
    });
    description = "A fully-functional example of using Poetry with Nix";
  };
  nix-pip-flake = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/nix-pip-flake/archive/refs/heads/main.tar.gz";
      sha256 = "1bswhb705kxpcr82a6yfifjwawifyj1ycdy1w4a471rzf3xkk03v";
    });
    description = "A fully-functional example of using a Python virtual environment with Nix";
  };
}
