{
  description = "Carl Thomé's personal Home Manager config";

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
            let f = name: pkgs.callPackage "${dir}/${name}" { };
            in mapDir dir f;
        in
        {
          apps = callPackages ./apps;
          packages = callPackages ./packages;
          legacyPackages.homeConfigurations = mapDir ./homes mkHome;
          nixosConfigurations = mapDir ./machines mkNixos;
          formatter = pkgs.nixpkgs-fmt;
          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                actionlint.enable = true;
                nixpkgs-fmt.enable = true;
                prettier.enable = true;
                shellcheck.enable = true;
                shfmt.enable = true;
                statix.enable = true;
              };
            };
          };
          devShells.default = pkgs.mkShell {
            name = self;
            packages = with pkgs; [
              act
              cachix
              git
              nix-diff
              nix-info
              nixpkgs-fmt
              pkgs.home-manager
            ];
            inherit (self.checks.${system}.pre-commit-check) shellHook;
          };
        };
    in
    flake-utils.lib.eachDefaultSystem mkSystem;
}
