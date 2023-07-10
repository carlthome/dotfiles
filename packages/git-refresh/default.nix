{ pkgs, git, findutils, ... }: pkgs.writeShellApplication {
  name = "git-refresh";
  runtimeInputs = [ git findutils ];
  text = builtins.readFile ./script.sh;
}
