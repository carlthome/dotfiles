{ config, pkgs, ... }: {

  # Configure graphics settings.
  hardware.graphics.enable = true;
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb.layout = "se";
  };

  # Configure audio settings.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };

  # Enable networking.
  networking.networkmanager.enable = true;

  # Enable Flatpak as a fallback for missing packages.
  services.flatpak.enable = true;

  # Find printers automatically.
  services.printing.enable = false;

  # Add additional GNOME programs.
  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
  environment.systemPackages = [ pkgs.gnomeExtensions.appindicator ];

  # Include Steam for all users.
  programs.steam.enable = true;

  # Add default web browser for all users.
  programs.firefox.enable = true;

  # Auto-build and reload shell.nix in the background.
  services.lorri.enable = true;
}
