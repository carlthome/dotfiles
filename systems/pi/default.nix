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
    {
      virtualisation.vmVariant = {
        virtualisation.host.pkgs = nixpkgs.legacyPackages.x86_64-linux;
        virtualisation.memorySize = 4 * 1024; # 4 GB
        virtualisation.diskSize = 32 * 1024; # 32 GB
        boot.kernelPackages = nixpkgs.lib.mkForce nixpkgs.legacyPackages.aarch64-linux.linuxPackages;
      };
    }
  ];
}
