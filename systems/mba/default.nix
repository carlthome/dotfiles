{ nix-darwin, self, ... }:

nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    ./configuration.nix
    #self.darwinModules.auto-tunnel
    self.darwinModules.auto-upgrade
    self.darwinModules.default
    #self.darwinModules.node-exporter
    self.darwinModules.terminal-profile
    self.darwinModules.wallpaper
    self.modules.default
  ];
}
