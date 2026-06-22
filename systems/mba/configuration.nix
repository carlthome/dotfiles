{ pkgs, ... }:
{
  networking.hostName = "mba";

  system.primaryUser = "carl";

  users.users.carl.openssh.authorizedKeys.keyFiles = [
    ./carl.pub
  ];

  # Since the disk is only 256 GB, garbage collect store paths when running out of space.
  nix.extraOptions = ''
    min-free = 100M
    max-free = 1G
  '';

  services.terminal-profile.enable = true;

  services.wallpaper = {
    enable = true;
    frequency = "daily";
  };

  services.auto-upgrade = {
    enable = true;
    flake = "github:carlthome/dotfiles";
  };

  #services.node-exporter = {
  #  enable = true;
  #  listen.address = "tailscale";
  #};

  # services.auto-tunnel = {
  #   enable = true;
  #   exitNode = "pi";
  #   trustedNetworks = [ ];
  #   trustedNetworksFile = "/etc/auto-tunnel/trusted-networks";
  # };

  system.stateVersion = 6;
}
