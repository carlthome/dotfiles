{
  description = "Carl Thomé's personal Home Manager config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-latest";
    };
  };

  outputs = { self, nixpkgs-stable, nixpkgs-latest, utils, home-manager, ... }:
    {
      homeConfigurations = {
        "carlthome@rtx3090" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs-latest.legacyPackages.x86_64-linux;
          modules = [
            ./home-configurations/global.nix
            ./home-configurations/linux.nix
            ./home-configurations/gpu.nix
            ./home-configurations/workstation.nix
          ];
        };

        "carl@t1" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs-latest.legacyPackages.x86_64-linux;
          modules = [
            ./home-configurations/global.nix
            ./home-configurations/linux.nix
            ./home-configurations/gpu.nix
            ./home-configurations/desktop.nix
          ];
        };

        "Carl@Betty" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs-latest.legacyPackages.aarch64-darwin;
          modules = [
            ./home-configurations/global.nix
            ./home-configurations/darwin.nix
          ];
        };
      };
    } // utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs-latest.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        # TODO Add flakes testing.
        #checks = { };

        # TODO Add example package.
        #packages = { };

        apps = rec {
          update-home = import ./apps/update-home.nix { inherit pkgs; };
          default = update-home;
        };

        devShells = rec {
          home-manager = import ./shells/home-manager.nix { inherit pkgs; };
          ipython = import ./shells/ipython.nix { inherit pkgs; };
          default = home-manager;
        };
      });
}
