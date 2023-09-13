{ nixpkgs, system, ... }@inputs:
let
  pkgs = nixpkgs.legacyPackages.${system};
  names = builtins.attrNames (pkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  mkPackage = name: pkgs.callPackage ./${name} inputs;
  packages = pkgs.lib.genAttrs names mkPackage;
  allPackages = packages: pkgs.symlinkJoin { name = "all"; paths = (builtins.attrValues packages); };
in
packages // { default = allPackages packages; }
