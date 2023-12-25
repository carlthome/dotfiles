{ nixpkgs, self, ... }: {
  t1 = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./t1/configuration.nix
      ./t1/hardware-configuration.nix
      self.nixosModules.default
      self.nixosModules.desktop
      self.nixosModules.cuda
    ];
  };

  pi = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      { sdImage.compressImage = false; }
      { nixpkgs.overlays = [ self.overlays.modules-closure ]; }
      ./pi/configuration.nix
      ./pi/hardware-configuration.nix
      self.nixosModules.default
      self.nixosModules.server
    ];
  };
}
