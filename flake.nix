{
  description = "Carl Thomé's personal Home Manager config";

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
        carlthome = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./home-configurations/shared.nix
            ./home-configurations/workstation.nix
            ./home-configurations/gpu.nix
          ];
        };

        carl = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./home-configurations/shared.nix
            ./home-configurations/desktop.nix
            ./home-configurations/gpu.nix
          ];
        };

        Carl = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [
            ./home-configurations/shared.nix
            ./home-configurations/laptop.nix
          ];
        };
      };
    } // utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
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
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ nixpkgs-fmt nixfmt cachix act vim git ];
            shellHook = ''
              echo "Hello $(whoami)!"
            '';
          };
        };
      });
}
