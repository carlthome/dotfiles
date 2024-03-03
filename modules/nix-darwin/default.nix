{ ... }: {
  auto-upgrade = import ./auto-upgrade.nix;
  default = import ./configuration.nix;
}
