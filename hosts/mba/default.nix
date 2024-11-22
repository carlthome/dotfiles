{ nix-darwin, self, ... }:

nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    ./configuration.nix
    ({ lib, ... }: { nix.settings.auto-optimise-store = lib.mkForce false; }) # TODO https://github.com/NixOS/nix/issues/7273
    self.darwinModules.auto-upgrade
    self.darwinModules.default
    self.modules.default
  ];
}
