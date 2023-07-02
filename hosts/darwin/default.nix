{ nix-darwin, nixpkgs }:
let
  names = builtins.attrNames (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  mkDarwin = name: nix-darwin.lib.darwinSystem {
    system = import ./${name}/system.nix;
    modules = [
      ../../modules/nix-darwin/configuration.nix
      ./${name}/configuration.nix
    ];
  };
in
nixpkgs.lib.genAttrs names mkDarwin
