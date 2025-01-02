{ pkgs, ... }: {
  networking.hostName = "mba";

  # Delete old store paths since the disk is only 256 GB.
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 0; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  # Automatically delete store paths when running out of disk space.
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';

  services.wallpaper = {
    enable = true;
    interval = "daily";
    category = "nature";
  };

  system.stateVersion = 5;
}
