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

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, nix-darwin, nix-index-database, pre-commit-hooks, epidemic-sound }:
    let
      mkSystem = system: {
        legacyPackages.homeConfigurations = import ./homes { inherit nixpkgs; inherit home-manager; inherit nix-index-database; inherit system; inherit epidemic-sound; inherit self; };
        packages = import ./packages { inherit nixpkgs; inherit system; inherit self; };
        checks = import ./pre-commit.nix { inherit pre-commit-hooks; inherit system; };
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
        devShells.default = import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; inherit (self.checks.${system}.pre-commit-check) shellHook; };
      };
    in
    flake-utils.lib.eachDefaultSystem mkSystem // {
      nixosConfigurations = import ./hosts/nixos { inherit nixpkgs; };
      darwinConfigurations = import ./hosts/darwin { inherit nixpkgs; inherit nix-darwin; };
    };
}
