{ config, pkgs, ... }: {

  # Configure graphics settings.
  hardware.opengl.enable = true;
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "se";
  };

  # Configure audio settings.
  sound.enable = true;
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
  services.printing.enable = true;

  # Add additional GNOME programs.
  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
  environment.systemPackages = [ pkgs.gnomeExtensions.appindicator ];

  # Include Steam for all users.
  programs.steam.enable = true;

  # Add default web browser for all users.
  programs.firefox.enable = true;

  # Make sure packages share files by scanning for duplicates.
  nix.settings.auto-optimise-store = true;

  # Limit resources used by Nix to not make the system irresponsive during upgrades.
  nix.settings.cores = 1;
  nix.settings.max-jobs = 1;
}
