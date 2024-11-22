{ nixpkgs, self, configuration, ... }:

nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  modules = [
    configuration
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    { sdImage.compressImage = false; }
    { nixpkgs.overlays = [ self.overlays.modules-closure ]; }
    ./configuration.nix
    ./hardware-configuration.nix
    self.nixosModules.default
    self.nixosModules.server
  ];
}
