{ pkgs, self, ... }: {
  type = "app";
  program = "${self.outputs.packages.tensorflow}/bin/ipython";
}
