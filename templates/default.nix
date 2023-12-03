{ ... }: {
  nix-jax-mnist = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/nix-jax-mnist/archive/refs/tags/v1.0.0.zip";
      sha256 = "16pn51kc39c6ifvabr0mpgpvg4qnpr4j303g66jbr61ifk7ybyz5";
    });
    description = "A fully-functional example of using JAX to train a MNIST classifier with Nix";
  };
  poetry2nix-example = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/poetry2nix-example/archive/refs/tags/v1.0.0.zip";
      sha256 = "04fwkyddj1pc2nhsg49fc1xh4irjgwy2plcp9b1rbxa0qr5bmjz9";
    });
    description = "A fully-functional example of using Poetry with Nix";
  };
  nix-pip-flake = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/nix-pip-flake/archive/refs/tags/v1.0.0.zip";
      sha256 = "1bswhb705kxpcr82a6yfifjwawifyj1ycdy1w4a471rzf3xkk03v";
    });
    description = "A fully-functional example of using a Python virtual environment with Nix";
  };
}
