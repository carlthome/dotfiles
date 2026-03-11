{ nixpkgs, ... }@inputs:
let
  names = builtins.attrNames (
    nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.)
  );
  mkHost = name: import ./${name} inputs;
  allSystems = nixpkgs.lib.genAttrs names mkHost;
  filterSystems = f: nixpkgs.lib.filterAttrs (_: f) allSystems;
  isDarwin = v: v ? system;
  isNixOS = v: !(v ? system);
in
{
  nixosConfigurations = filterSystems isNixOS;
  darwinConfigurations = filterSystems isDarwin;
}
