{ pkgs, self, ... }: {
  type = "app";
  program = "${self.outputs.packages.sklearn}/bin/ipython";
}
