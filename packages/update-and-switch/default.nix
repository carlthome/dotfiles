{ pkgs, git, ... }:
pkgs.writeShellApplication {
  name = "update-and-switch";
  runtimeInputs = [ git ];
  text = builtins.readFile ./script.sh;
}
