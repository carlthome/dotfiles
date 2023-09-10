{ nix-darwin, nixpkgs, self, ... }:
let
  names = builtins.attrNames (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  mkDarwin = name: nix-darwin.lib.darwinSystem {
    system = import ./${name}/system.nix;
    modules = [
      ./${name}/configuration.nix
      self.darwinModules.default
    ];
  };
in
nixpkgs.lib.genAttrs names mkDarwin
