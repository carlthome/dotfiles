{ pkgs, ... }: pkgs.writeScriptBin "git-refresh" (builtins.readFile ./script.sh)
