{
  description = "Carl Thomé's personal computing configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = { url = "github:nix-community/home-manager/release-24.05"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-darwin = { url = "github:lnl7/nix-darwin/master"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-index-database = { url = "github:nix-community/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    mirpkgs = { url = "github:carlthome/mirpkgs/main"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixvim = { url = "github:nix-community/nixvim/nixos-24.05"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      mkSystem = system: {
        legacyPackages.homeConfigurations = import ./homes (inputs // { inherit system; });
        packages = import ./packages (inputs // { inherit system; });
        checks = import ./pre-commit.nix (inputs // { inherit system; });
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
        devShells.default = import ./shell.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          shellHook = self.checks.${system}.pre-commit-check.shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      };
    in
    flake-utils.lib.eachSystem systems mkSystem // {
      nixosConfigurations = import ./hosts inputs;
      darwinConfigurations = import ./hosts inputs;
      nixosModules = import ./modules/nixos inputs;
      darwinModules = import ./modules/nix-darwin inputs;
      homeModules = import ./modules/home-manager inputs;
      modules = import ./modules inputs;
      overlays = import ./overlays inputs;
      templates = import ./templates inputs;
    };
}
