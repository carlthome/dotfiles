{ nixpkgs, system, self, ... }@inputs:
let
  names = builtins.attrNames (builtins.readDir ./.);
  args = inputs // { inherit system; inherit self; };
  mkHome = name: import ./${name} args;
in
nixpkgs.lib.genAttrs names mkHome
