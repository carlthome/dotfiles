{ pkgs, ... }: pkgs.writeScriptBin "oom-test" (builtins.readFile ./script.sh)
