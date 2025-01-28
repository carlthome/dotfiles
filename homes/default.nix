{
  nixpkgs,
  system,
  self,
  ...
}@inputs:
let
  names = builtins.attrNames (
    nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.)
  );
  args = inputs // {
    inherit system;
    inherit self;
  };
  mkHome = name: import ./${name} args;
in
nixpkgs.lib.genAttrs names mkHome
