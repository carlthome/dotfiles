{ pkgs, ... }: pkgs.writeScriptBin "git-clone-all" (builtins.readFile ./script.sh)
