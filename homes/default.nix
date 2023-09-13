{ home-manager, nixpkgs, nix-index-database, system, self, ... }@inputs:
let
  names = builtins.attrNames (builtins.readDir ./.);
  mkHome = name: home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { inherit system; overlays = [ ]; };
    modules = [
      ./${name}/home.nix
      nix-index-database.hmModules.nix-index
      self.homeModules.home
      self.homeModules.${system}
    ];
    extraSpecialArgs = inputs;
  };
in
nixpkgs.lib.genAttrs names mkHome
