{ pkgs, fzf, ripgrep, bat, ... }: pkgs.writeShellApplication {
  name = "fzf-ripgrep";
  runtimeInputs = [ fzf ripgrep bat ];
  text = builtins.readFile ./script.sh;
}
