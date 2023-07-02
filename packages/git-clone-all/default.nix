{ pkgs, ... }: pkgs.writeScriptBin "script" (builtins.readFile ./script.sh)
