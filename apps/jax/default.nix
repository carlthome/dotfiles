{ pkgs, self, ... }: {
  type = "app";
  program = "${self.outputs.packages.jax}/bin/ipython";
}
