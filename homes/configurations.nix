{ home-manager, nixpkgs-latest, nixpkgs-stable }: {
  "carlthome@rtx3090" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs-latest.legacyPackages.x86_64-linux;
    modules = [
      ./modules/global.nix
      ./modules/linux.nix
      ./modules/gpu.nix
      ./modules/workstation.nix
    ];
  };

  "carl@t1" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs-latest.legacyPackages.x86_64-linux;
    modules = [
      ./modules/global.nix
      ./modules/linux.nix
      ./modules/gpu.nix
      ./modules/desktop.nix
    ];

  };

  "Carl@Betty.local" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs-latest.legacyPackages.aarch64-darwin;
    modules = [
      ./modules/global.nix
      ./modules/darwin.nix
    ];
  };
}
