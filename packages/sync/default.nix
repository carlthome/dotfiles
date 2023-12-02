{ pkgs, git, ... }: pkgs.writeShellApplication {
  name = "sync";
  runtimeInputs = [ git ];
  text = builtins.readFile ./script.sh;
}
