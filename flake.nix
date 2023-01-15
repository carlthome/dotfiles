{
  description = "Carl Thomé's personal Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs";
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
      rec {
        packages = {
          sklearn = import ./packages/sklearn.nix { inherit pkgs; };
          jax = import ./packages/jax.nix { inherit pkgs; };
          pytorch = import ./packages/pytorch.nix { inherit pkgs; };
          tensorflow = import ./packages/tensorflow.nix { inherit pkgs; };
        };

        apps = {
          default = import ./apps/update.nix { inherit pkgs; inherit self; inherit system; };
          switch-home = import ./apps/switch-home.nix { inherit pkgs; inherit self; };
          switch-system = import ./apps/switch-system.nix { inherit pkgs; inherit self; };
          sklearn = flake-utils.lib.mkApp { drv = packages.sklearn; name = "ipython"; };
          jax = flake-utils.lib.mkApp { drv = packages.jax; name = "ipython"; };
          pytorch = flake-utils.lib.mkApp { drv = packages.pytorch; name = "ipython"; };
          tensorflow = flake-utils.lib.mkApp { drv = packages.tensorflow; name = "ipython"; };
        };

        formatter = pkgs.nixpkgs-fmt;
        devShell = import ./shell.nix { inherit pkgs; };
      });
}
