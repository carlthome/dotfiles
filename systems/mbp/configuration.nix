{ pkgs, ... }:
{
  networking.hostName = "mbp";

  services.auto-upgrade = {
    enable = true;
    flake = "github:carlthome/dotfiles";
  };

  system.stateVersion = 6;
}
