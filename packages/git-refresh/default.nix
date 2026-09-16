{
  pkgs,
  git,
  findutils,
  direnv,
  ...
}:
pkgs.writeShellApplication {
  name = "git-refresh";
  runtimeInputs = [
    git
    findutils
    direnv
  ];
  text = builtins.readFile ./script.sh;
}
