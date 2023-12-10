{ config, pkgs, ... }: {

  # Boot sequence settings.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot/efi";
    initrd.secrets = { "/crypto_keyfile.bin" = null; };
  };

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

  # Provide suggestions of packages to install when a command is not found.
  programs.command-not-found.enable = true;
}
