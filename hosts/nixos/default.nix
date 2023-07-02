{ nixpkgs, ... }:
let
  names = builtins.attrNames (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  mkNixos = name: nixpkgs.lib.nixosSystem {
    system = import ./${name}/system.nix;
    modules = [
      ../../modules/nixos/configuration.nix
      ./${name}/hardware-configuration.nix
      ./${name}/configuration.nix
    ];
  };
in
nixpkgs.lib.genAttrs names mkNixos
