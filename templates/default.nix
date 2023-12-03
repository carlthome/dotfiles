{ ... }: {
  nix-jax-mnist = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/nix-jax-mnist/archive/refs/tags/v1.0.0.zip";
      sha256 = "1dwrhj9vj03x6ni9jgyb6fvbm48ply392sjh5d1x4a2hn4h5ydjx";
    });
    description = "A fully-functional example of using JAX to train a MNIST classifier with Nix";
  };
  poetry2nix-example = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/poetry2nix-example/archive/refs/tags/v1.0.0.zip";
      sha256 = "1z86j01k5fji883fl6n1fmp49z9ckrgzrqz6v75g8wnb3n81gw7l";
    });
    description = "A fully-functional example of using Poetry with Nix";
  };
  nix-pip-flake = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/nix-pip-flake/archive/refs/tags/v1.0.0.zip";
      sha256 = "02dk1zg2dag3c3d6hh5yjd0bip10sl5ifdz07cvw85cq8i5gmfly";
    });
    description = "A fully-functional example of using a Python virtual environment with Nix";
  };
}
