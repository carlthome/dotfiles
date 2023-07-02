{ pkgs, ... }: pkgs.writeScriptBin "list-extensions" (builtins.readFile ./script.sh)
