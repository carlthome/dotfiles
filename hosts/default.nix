{ nixpkgs, nix-darwin, self, ... }: {
  t1 = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
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
      ./configuration.nix
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      { sdImage.compressImage = false; }
      { nixpkgs.overlays = [ self.overlays.modules-closure ]; }
      ./pi/configuration.nix
      ./pi/hardware-configuration.nix
      self.nixosModules.default
      self.nixosModules.server
    ];
  };

  mbp = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      ./configuration.nix
      ./mbp/configuration.nix
      self.darwinModules.default
    ];
  };

  Betty = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      ./configuration.nix
      ./Betty/configuration.nix
      self.darwinModules.default
    ];
  };
}
