{ ... }: {
  auto-upgrade = import ./auto-upgrade.nix;
  wallpaper = import ./wallpaper.nix;
  default = import ./configuration.nix;
}
