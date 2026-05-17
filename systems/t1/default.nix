{ nixpkgs, self, ... }:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    self.modules.default
    self.nixosModules.cuda
    self.nixosModules.default
    self.nixosModules.desktop
  ];
}
