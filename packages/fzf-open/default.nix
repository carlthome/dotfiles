{ pkgs, fzf, fd, ... }: pkgs.writeShellApplication {
  name = "fzf-open";
  runtimeInputs = [ fzf fd ];
  text = builtins.readFile ./script.sh;
}
