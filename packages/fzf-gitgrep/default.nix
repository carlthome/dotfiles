{
  pkgs,
  fzf,
  git,
  bat,
  ...
}:
pkgs.writeShellApplication {
  name = "fzf-gitgrep";
  runtimeInputs = [
    fzf
    git
    bat
  ];
  text = builtins.readFile ./script.sh;
}
