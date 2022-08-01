{
  description = "My personal config for learning more about flakes and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, home-manager, ... }:
    {
      homeConfigurations = {
        "carl@t1" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./home-configurations/home.nix
            ./home-configurations/t1.nix
          ];
        };

        "Carl@Betty" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [
            ./home-configurations/home.nix
            ./home-configurations/m1.nix
          ];
        };
      };
    } // utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          hello = pkgs.hello;
          default = hello;
        };
        apps = rec {

          update-home = {
            type = "app";
            program = (pkgs.writeScript "update-home" ''
              profile=$(nix profile list | grep home-manager-path | head -n1 | awk '{print $4}')
              nix profile remove $profile
              home-manager switch --flake .
            '').outPath;
          };

          default = update-home;
        };

        devShells = {
          default = import ./shell.nix { inherit pkgs; };
        };
      });
}
