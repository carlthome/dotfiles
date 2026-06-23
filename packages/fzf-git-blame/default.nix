{
  pkgs,
  fzf,
  ripgrep,
  bat,
  git,
  less,
  ...
}:
pkgs.writeShellApplication {
  name = "fzf-git-blame";
  runtimeInputs = [
    fzf
    ripgrep
    bat
    git
    less
  ];
  text = builtins.readFile ./script.sh;
}
