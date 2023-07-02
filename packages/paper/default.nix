{ pkgs, ... }: pkgs.writeScriptBin "paper" (builtins.readFile ./script.sh)
