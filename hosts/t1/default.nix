{ nixpkgs, self, configuration, ... }:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    configuration
    ./configuration.nix
    ./hardware-configuration.nix
    self.nixosModules.default
    self.nixosModules.desktop
    self.nixosModules.cuda
  ];
}
