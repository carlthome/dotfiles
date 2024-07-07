{ pkgs, gh, gnused, ... }: pkgs.writeShellApplication {
  name = "github-actions-dashboard-creator";
  runtimeInputs = [ gh gnused ];
  text = builtins.readFile ./script.sh;
}
