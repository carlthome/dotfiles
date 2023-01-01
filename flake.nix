{
  description = "Carl Thomé's personal Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager }:
    {
      homeConfigurations = {
        "carlthome@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./modules/global.nix
            ./modules/linux.nix
            ./modules/gpu.nix
            ./modules/work.nix
          ];
        };

        "carl@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./modules/global.nix
            ./modules/linux.nix
            ./modules/gpu.nix
            ./modules/home.nix
          ];
        };

        "carl@aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [
            ./modules/global.nix
            ./modules/darwin.nix
            ./modules/home.nix
          ];
        };

        "carlthome@aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [
            ./modules/global.nix
            ./modules/darwin.nix
            ./modules/work.nix
          ];
        };
      };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./modules/nixos.nix ];
        };
      };

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        # TODO Add flakes testing.
        #checks = { };

        # TODO Add example package.
        #packages = { };

        apps = rec {
          update-home = import ./apps/update-home.nix { inherit pkgs; };
          update-system = import ./apps/update-system.nix { inherit pkgs; };
          default = update-home;
        };

        devShells = rec {
          home-manager = import ./shells/home-manager.nix { inherit pkgs; };
          ipython = import ./shells/ipython.nix { inherit pkgs; };
          default = home-manager;
        };
      });
}
