{ nixpkgs, ... }@inputs:
let
  names = builtins.attrNames (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  mkHost = name: import ./${name} inputs;
in
nixpkgs.lib.genAttrs names mkHost
