{ pkgs, fzf, ... }: pkgs.writeShellApplication {
  name = "fzf-open";
  runtimeInputs = [ fzf ];
  text = builtins.readFile ./script.sh;
}
