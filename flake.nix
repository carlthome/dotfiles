{
  description = "Carl Thomé's personal Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jupyterWith.url = "github:tweag/jupyterWith";
  };

  outputs = { self, nixpkgs, utils, home-manager, jupyterWith }:
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
      let
        pkgs = import nixpkgs {
          system = system;
          overlays = nixpkgs.lib.attrValues jupyterWith.overlays;
        };

        jax = pkgs.kernels.iPythonWith {
          name = "Flax";
          packages = p: with p; [
            flax
            jax
            jaxlib

            #matplotlib
            #numpy
            #pytorch
            #sympy
            #tensorflow
            #torchmetrics
            #torchvision
          ];
          #ignoreCollisions = true;
        };

        jupyterEnvironment = pkgs.jupyterlabWith {
          kernels = [ jax ];
        };

      in
      {
        packages = {
          default = pkgs.hello;
        };

        apps = {

          default = {
            type = "app";
            program = (pkgs.writeScript "update-home" ''
              set -e
              profile=$(nix profile list | grep home-manager-path | head -n1 | awk '{print $4}')
              home-manager build --flake .
              nix profile remove $profile
              home-manager switch --flake .
            '').outPath;
          };

          jupyter = {
            type = "app";
            program = "${jupyterEnvironment}/bin/jupyter-lab";
          };

        };

        devShells = {

          default = pkgs.mkShell {
            name = "nix";
            buildInputs = with pkgs; [ nixpkgs-fmt nixfmt cachix act vim git ];
            shellHook = ''
              echo "Hello $(whoami)!"
            '';
          };

          jupyter = jupyterEnvironment.env;

          ipython = pkgs.mkShell {
            name = "NumPy";
            buildInputs = with pkgs;
              let
                env = python3.withPackages (ps: with ps; [
                  ipython
                  matplotlib
                  numpy
                  pandas
                  scipy
                ]);
              in
              [ env ];
            shellHook = ''
              ipython
            '';
          };
        };
      });
}
