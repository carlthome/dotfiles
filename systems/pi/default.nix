{ nixpkgs, self, ... }:

nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    { nixpkgs.overlays = [ self.overlays.modules-closure ]; }
    { sdImage.compressImage = false; }
    self.modules.default
    self.nixosModules.default
    self.nixosModules.server
  ];
}
