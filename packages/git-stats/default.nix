{ pkgs, gh, ... }: pkgs.writeShellApplication {
  name = "git-stats";
  runtimeInputs = [ gh ];
  text = builtins.readFile ./script.sh;
}
