{ home-manager, nixpkgs, nix-index-database, system, self, epidemic-sound, ... }:
let
  names = builtins.attrNames (builtins.readDir ./.);
  mkHome = name: home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { inherit system; overlays = [ ]; };
    modules = [
      ./${name}/home.nix
      nix-index-database.hmModules.nix-index
      self.homeModules.default
      self.homeModules.${system}
    ];
    extraSpecialArgs = { inherit self; inherit epidemic-sound; };
  };
in
nixpkgs.lib.genAttrs names mkHome
