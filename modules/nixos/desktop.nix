{ config, pkgs, ... }:
{

  # Configure graphics user interface.
  hardware.graphics.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure audio settings.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "soft";
      value = "99999";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "99999";
    }
  ];

  # Enable networking.
  networking.networkmanager.enable = true;

  # Enable Flatpak as a fallback for missing packages.
  services.flatpak.enable = true;

  # Don't find printers automatically.
  services.printing.enable = false;

  # To get systray icons support.
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  # Add additional software for all users.
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    mission-center
    monitorets
    resources
  ];

  # Include Steam for all users.
  programs.steam.enable = true;

  # TODO Add default web browser for all users.
  # https://github.com/NixOS/nixpkgs/pull/457391#issuecomment-3622359217
  # programs.firefox.enable = true;

  # Auto-build and reload shell.nix in the background.
  services.lorri.enable = true;

  # Provide suggestions of packages to install when a command is not found.
  programs.command-not-found.enable = true;

  # Set Nix daemon to use lower scheduling priority.
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";
}
