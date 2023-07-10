{ pkgs, git, gh, ... }: pkgs.writeShellApplication {
  name = "git-clone-all";
  runtimeInputs = [ git gh ];
  text = builtins.readFile ./script.sh;
}
