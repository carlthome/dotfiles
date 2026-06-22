{ ... }:
{
  #auto-tunnel = import ./auto-tunnel;
  auto-upgrade = import ./auto-upgrade.nix;
  #node-exporter = import ./node-exporter;
  terminal-profile = import ./terminal-profile;
  wallpaper = import ./wallpaper.nix;
  default = import ./configuration.nix;
}
