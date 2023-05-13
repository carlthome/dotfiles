{
  description = "Carl Thomé's personal computing configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin = { url = "github:lnl7/nix-darwin/master"; inputs.nixpkgs.follows = "nixpkgs"; };
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager = { url = "github:nix-community/home-manager/release-22.11"; inputs.nixpkgs.follows = "nixpkgs"; };
    epidemic-sound = { url = "git+ssh://git@github.com/epidemicsound/home-manager.git?ref=main"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, flake-utils, pre-commit-hooks, home-manager, epidemic-sound }@inputs:
    let
      mapDir = d: f:
        let names = builtins.attrNames (builtins.readDir d);
        in nixpkgs.lib.genAttrs names f;

      mkNixos = name: nixpkgs.lib.nixosSystem {
        system = (import ./hosts/nixos/${name}/system.nix).system;
        modules = [
          ./modules/nixos/configuration.nix
          ./hosts/nixos/${name}/hardware-configuration.nix
          ./hosts/nixos/${name}/configuration.nix
        ];
      };

      mkDarwin = name: nix-darwin.lib.darwinSystem {
        system = (import ./hosts/darwin/${name}/system.nix).system;
        modules = [
          ./modules/nix-darwin/configuration.nix
          ./hosts/darwin/${name}/configuration.nix
        ];
      };

      mkHome = system: name: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./modules/home-manager/home.nix
          ./modules/home-manager/${system}.nix
          ./homes/${name}/home.nix
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
