{ nix-darwin, self, configuration, ... }:

nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    configuration
    ./configuration.nix
    self.darwinModules.auto-upgrade
    self.darwinModules.default
    ({ lib, ... }: { nix.settings.auto-optimise-store = lib.mkForce false; }) # TODO https://github.com/NixOS/nix/issues/7273
  ];
}
