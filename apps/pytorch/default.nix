{ pkgs, self, ... }: {
  type = "app";
  program = "${self.outputs.packages.pytorch}/bin/ipython";
}
