{ pkgs, fzf, kubectl, gnused, ... }: pkgs.writeShellApplication {
  name = "k8s-pods-logs";
  runtimeInputs = [ fzf kubectl gnused ];
  text = builtins.readFile ./script.sh;
}
