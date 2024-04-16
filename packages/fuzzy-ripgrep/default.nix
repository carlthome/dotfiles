{ pkgs, fzf, ripgrep, bat, ... }: pkgs.writeShellApplication {
  name = "fuzzy-ripgrep";
  runtimeInputs = [ fzf ripgrep bat ];
  text = builtins.readFile ./script.sh;
}
