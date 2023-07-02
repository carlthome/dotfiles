{ home-manager, nixpkgs, nix-index-database, system, self, epidemic-sound, ... }:
let
  names = builtins.attrNames (builtins.readDir ./.);
  mkHome = name: home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs { inherit system; overlays = [ ]; };
    modules = [
      ../modules/home-manager/home.nix
      ../modules/home-manager/${system}.nix
      ./${name}/home.nix
      nix-index-database.hmModules.nix-index
    ];
    extraSpecialArgs = { inherit self; inherit epidemic-sound; };
  };
in
nixpkgs.lib.genAttrs names mkHome
