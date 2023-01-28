{
  description = "Carl Thomé's personal Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, pre-commit-hooks, home-manager }:
    {
      homeConfigurations =
        let
          home = {
            name = "Carl Thomé";
            handle = "carl";
            email = "carlthome@gmail.com";
          };
          work = {
            name = "Carl Thomé";
            handle = "carlthome";
            email = "carl.thome@epidemicsound.com";
          };
        in
        {
          "${work.handle}@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              ./modules/home.nix
              ./modules/x86_64-linux.nix
              ./modules/gpu.nix
            ];
            extraSpecialArgs = {
              user = work;
            };
          };

          "${home.handle}@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              ./modules/home.nix
              ./modules/x86_64-linux.nix
              ./modules/gpu.nix
            ];
            extraSpecialArgs = {
              user = home;
            };
          };

          "${home.handle}@aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.aarch64-darwin;
            modules = [
              ./modules/home.nix
              ./modules/aarch64-darwin.nix
            ];
            extraSpecialArgs = {
              user = home;
            };
          };

          "${work.handle}@aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.aarch64-darwin;
            modules = [
              ./modules/home.nix
              ./modules/aarch64-darwin.nix
            ];
            extraSpecialArgs = {
              user = work;
            };
          };
        };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./modules/nixos.nix
            ./modules/substituters.nix
            ./machines/t1/hardware-configuration.nix
          ];
        };
      };

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      in
      rec {

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              actionlint.enable = true;
              nixpkgs-fmt.enable = true;
              prettier.enable = true;
              shellcheck.enable = true;
              shfmt.enable = true;
              statix.enable = true;
            };
          };
        };

        packages = {
          sklearn = import ./packages/sklearn.nix { pkgs = pkgs-unstable; };
          jax = import ./packages/jax.nix { pkgs = pkgs-unstable; };
          pytorch = import ./packages/pytorch.nix { pkgs = pkgs-unstable; };
          tensorflow = import ./packages/tensorflow.nix { pkgs = pkgs-unstable; };
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

        devShells.default = pkgs.mkShell {
          name = "home-manager";
          packages = with pkgs; [
            act
            cachix
            git
            nix-diff
            nix-info
            nixpkgs-fmt
            pkgs.home-manager
          ];
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      });
}
