{
  description = "Carl Thomé's personal computing configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mirpkgs = {
      url = "github:carlthome/mirpkgs/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cargo2nix = {
      url = "github:cargo2nix/cargo2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      mkSystem = system: {
        legacyPackages.homeConfigurations = import ./homes (inputs // { inherit system; });
        packages = import ./packages (inputs // { inherit system; });
        checks = import ./pre-commit.nix (inputs // { inherit system; });
        formatter = nixpkgs.legacyPackages.${system}.nixfmt-tree;
        devShells.default = import ./shell.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          shellHook = self.checks.${system}.pre-commit-check.shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      };
      allSystems = import ./systems inputs;
    in
    flake-utils.lib.eachSystem systems mkSystem
    // {
      nixosConfigurations = allSystems.nixosConfigurations;
      darwinConfigurations = allSystems.darwinConfigurations;
      nixosModules = import ./modules/nixos inputs;
      darwinModules = import ./modules/nix-darwin inputs;
      homeModules = import ./modules/home-manager inputs;
      modules = import ./modules inputs;
      overlays = import ./overlays inputs;
      # TODO Temporarily disabled since failing new schema checks from upstream.
      #templates = import ./templates inputs;
    };
}
