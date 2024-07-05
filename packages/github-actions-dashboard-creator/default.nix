{ pkgs, gh, sed, ... }: pkgs.writeShellApplication {
  name = "github-actions-dashboard-creator";
  runtimeInputs = [ gh sed ];
  text = builtins.readFile ./script.sh;
}
