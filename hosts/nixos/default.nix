{ nixpkgs, self, ... }:
let
  names = builtins.attrNames (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  mkNixos = name: nixpkgs.lib.nixosSystem {
    system = import ./${name}/system.nix;
    modules = [
      ./${name}/hardware-configuration.nix
      ./${name}/configuration.nix
      self.nixosModules.default
    ];
  };
in
nixpkgs.lib.genAttrs names mkNixos
