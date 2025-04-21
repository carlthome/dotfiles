{ pkgs, ... }:
{
  networking.hostName = "mba";

  # Since the disk is only 256 GB, garbage collect store paths when running out of space.
  nix.extraOptions = ''
    min-free = 100M
    max-free = 1G
  '';

  services.wallpaper = {
    enable = true;
    interval = "daily";
    category = "nature";
  };

  services.auto-upgrade = {
    enable = true;
    flake = "github:carlthome/dotfiles";
  };

  system.stateVersion = 5;
}
