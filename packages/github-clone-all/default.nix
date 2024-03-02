{ pkgs, git, gh, ... }: pkgs.writeShellApplication {
  name = "github-clone-all";
  runtimeInputs = [ git gh ];
  text = builtins.readFile ./script.sh;
}
