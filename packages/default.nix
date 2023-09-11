{ nixpkgs, system, ... }@inputs:
let
  pkgs = nixpkgs.legacyPackages.${system};
  names = builtins.attrNames (pkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  mkPackage = name: pkgs.callPackage ./${name} inputs;
in
pkgs.lib.genAttrs names mkPackage
