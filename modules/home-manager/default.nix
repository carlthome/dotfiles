{ nixpkgs, ... }:
let
  names = builtins.attrNames (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  importModule = name: import ./${name};
in
nixpkgs.lib.genAttrs names importModule
