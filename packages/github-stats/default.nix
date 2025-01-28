{ pkgs, gh, ... }:
pkgs.writeShellApplication {
  name = "github-stats";
  runtimeInputs = [ gh ];
  text = builtins.readFile ./script.sh;
}
