{
  description = "My personal config for learning more about flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, flake-utils, home-manager, ... }:
    {
      homeConfigurations."carl@t1" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home-configurations/home.nix
          ./home-configurations/t1.nix
        ];
      };
      homeConfigurations."Carl@Betty" = home-manager.lib.homeManagerConfiguration
        {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [
            ./home-configurations/home.nix
            ./home-configurations/m1.nix
          ];
        };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          hello = pkgs.hello;
          default = hello;
        };
        apps = { };
        devShells.default = import ./shell.nix { inherit pkgs; };
      });
}
