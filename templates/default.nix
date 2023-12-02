{ ... }: {
  nix-jax-mnist = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/nix-jax-mnist/archive/refs/heads/main.tar.gz";
      sha256 = "1dd058mpjyzq9krc81prchl0gcvwd0al1s1shd1wi8pabg6mpim1";
    });
    description = "A fully-functional example of using JAX to train a MNIST classifier with Nix";
  };
  poetry2nix-example = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/poetry2nix-example/archive/refs/heads/main.tar.gz";
      sha256 = "1pi9rjg820rik66q13aq1hb0kvklpchbfkiqhaf9za6ap2lkgv6n";
    });
    description = "A fully-functional example of using Poetry with Nix";
  };
  nix-pip-flake = {
    path = (builtins.fetchTarball {
      url = "https://github.com/carlthome/nix-pip-flake/archive/refs/heads/main.tar.gz";
      sha256 = "03kd0iif4ckqdav8y1cpvm31ysg0sg0lhq1gf7l3ac813n9q5zx8";
    });
    description = "A fully-functional example of using a Python virtual environment with Nix";
  };
}
