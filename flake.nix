{
  description = "Carl Thomé's personal Home Manager config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = { self, nixpkgs-stable, nixpkgs-latest, flake-utils, home-manager }:
    {
      homeConfigurations = import ./homes/configurations.nix { inherit home-manager; nixpkgs = nixpkgs-stable; };
      nixosConfigurations.nixos = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./homes/modules/nixos.nix ];
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs-stable.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixfmt;

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
