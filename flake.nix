{
  description = "Carl Thomé's personal Home Manager config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-latest";
    };
  };

  outputs = { self, nixpkgs-stable, nixpkgs-latest, flake-utils, home-manager }:
    {
      homeConfigurations = import ./homes/configurations.nix { inherit home-manager; inherit nixpkgs-stable; inherit nixpkgs-latest; };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs-latest.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixfmt;

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
