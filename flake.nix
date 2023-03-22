{
  description = "Carl Thomé's personal computing configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, darwin, flake-utils, pre-commit-hooks, home-manager }:
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

      mkDarwin = name: darwin.lib.darwinSystem {
        system = (import ./hosts/darwin/${name}/system.nix).system;
        modules = [
          ./modules/darwin/configuration.nix
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
