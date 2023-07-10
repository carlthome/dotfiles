{ pkgs, findutils, coreutils, less, ... }: pkgs.writeShellApplication {
  name = "list-extensions";
  runtimeInputs = [ findutils coreutils less ];
  text = builtins.readFile ./script.sh;
}
