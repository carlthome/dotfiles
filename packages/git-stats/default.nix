{ pkgs, ... }: pkgs.writeScriptBin "git-stats" (builtins.readFile ./script.sh)
