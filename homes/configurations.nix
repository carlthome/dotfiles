{ home-manager, nixpkgs-latest, nixpkgs-stable }: {

  "carlthome@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs-latest.legacyPackages.x86_64-linux;
    modules = [
      ./modules/global.nix
      ./modules/linux.nix
      ./modules/gpu.nix
      ./modules/work.nix
    ];
  };

  "carl@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs-latest.legacyPackages.x86_64-linux;
    modules = [
      ./modules/global.nix
      ./modules/linux.nix
      ./modules/gpu.nix
      ./modules/home.nix
    ];
  };

  "carl@aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs-latest.legacyPackages.aarch64-darwin;
    modules = [
      ./modules/global.nix
      ./modules/darwin.nix
      ./modules/home.nix
    ];
  };

  "carlthome@aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs-latest.legacyPackages.aarch64-darwin;
    modules = [
      ./modules/global.nix
      ./modules/darwin.nix
      ./modules/work.nix
    ];
  };
}
