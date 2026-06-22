{
  pkgs,
  fzf,
  git,
  less,
  ...
}:
pkgs.writeShellApplication {
  name = "fzf-git-log";
  runtimeInputs = [
    fzf
    git
    less
  ];
  text = builtins.readFile ./script.sh;
}
