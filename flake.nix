{
  description = "Carl Thomé's personal computing configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = { url = "github:nix-community/home-manager/release-23.05"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-darwin = { url = "github:lnl7/nix-darwin/master"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-index-database = { url = "github:Mic92/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    epidemic-sound = { url = "git+ssh://git@github.com/epidemicsound/home-manager.git?ref=main"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, nix-darwin, nix-index-database, pre-commit-hooks, epidemic-sound }@inputs:
    let
      mapDir = d: f:
        let names = builtins.attrNames (builtins.readDir d);
        in nixpkgs.lib.genAttrs names f;

      mkNixos = name: nixpkgs.lib.nixosSystem {
        system = import ./hosts/nixos/${name}/system.nix;
        modules = [
          ./modules/nixos/configuration.nix
          ./hosts/nixos/${name}/hardware-configuration.nix
          ./hosts/nixos/${name}/configuration.nix
        ];
      };

      mkDarwin = name: nix-darwin.lib.darwinSystem {
        system = import ./hosts/darwin/${name}/system.nix;
        modules = [
          ./modules/nix-darwin/configuration.nix
          ./hosts/darwin/${name}/configuration.nix
        ];
      };

      mkHome = system: name: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; overlays = [ ]; };
        modules = [
          ./modules/home-manager/home.nix
          ./modules/home-manager/${system}.nix
          ./homes/${name}/home.nix
          nix-index-database.hmModules.nix-index
        ];
        extraSpecialArgs = inputs;
      };

      mkSystem = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pre-commit = pre-commit-hooks.lib.${system};
          shellHook = self.checks.${system}.pre-commit-check.shellHook;
          callPackages = dir:
            let f = name: pkgs.callPackage "${dir}/${name}" { inherit self; inherit shellHook; inherit pre-commit; };
            in mapDir dir f;
        in
        {
          checks = callPackages ./checks;
          packages = callPackages ./packages;
          apps = callPackages ./apps;
          formatter = pkgs.nixpkgs-fmt;
          legacyPackages.homeConfigurations = mapDir ./homes (mkHome system);
        };
    in
    flake-utils.lib.eachDefaultSystem mkSystem // {
      nixosConfigurations = mapDir ./hosts/nixos mkNixos;
      darwinConfigurations = mapDir ./hosts/darwin mkDarwin;
    };
}
