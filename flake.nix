{
  description = "Carl Thomé's personal computing configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, pre-commit-hooks, home-manager }:
    let
      mkSystem = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
          pre-commit = pre-commit-hooks.lib.${system};
          shellHook = self.checks.${system}.pre-commit-check.shellHook;

          mkHome = name: home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./modules/home.nix
              ./modules/${system}.nix
              ./homes/${name}/home.nix
            ];
          };

          mkNixos = name: nixpkgs.lib.nixosSystem {
            system = (import ./machines/${name}/system.nix).system;
            modules = [
              ./modules/nixos.nix
              ./machines/${name}/hardware-configuration.nix
              ./machines/${name}/configuration.nix
            ];
          };

          mapDir = d: f:
            let names = builtins.attrNames (builtins.readDir d);
            in pkgs.lib.genAttrs names f;

          callPackages = dir:
            let f = name: pkgs.callPackage "${dir}/${name}" { inherit self; inherit shellHook; inherit pre-commit; };
            in mapDir dir f;
        in
        {
          checks = callPackages ./checks;
          packages = callPackages ./packages;
          apps = callPackages ./apps;
          formatter = pkgs.nixpkgs-fmt;
          legacyPackages.homeConfigurations = mapDir ./homes mkHome;
          legacyPackages.nixosConfigurations = mapDir ./machines mkNixos;
        };
    in
    flake-utils.lib.eachDefaultSystem mkSystem;
}
