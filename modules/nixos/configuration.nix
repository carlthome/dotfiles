{ config, pkgs, ... }: {

  # Configure Nix program itself.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Enable automatic garbage collection.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Boot sequence settings.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot/efi";
    initrd.secrets = { "/crypto_keyfile.bin" = null; };
  };

  # Select locale, time zone and default keyboard layout.
  console.keyMap = "sv-latin1";
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable networking.
  networking.networkmanager.enable = true;

  # Enable OpenGL.
  hardware.opengl.enable = true;

  # Enable real-time audio for PipeWire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Set default shell for all users.
  users.defaultUserShell = pkgs.fish;

  # Set a basic default environment for all users.
  environment = {
    systemPackages = with pkgs; [
      vim
      gnomeExtensions.appindicator
    ];
    shellAliases = {
      switch-system = "nixos-rebuild switch --flake .";
      list-generations = "nix-env --list-generations";
    };
    shells = [ pkgs.fish ];
    variables = {
      EDITOR = "vim";
      # TODO https://github.com/NixOS/nixpkgs/issues/32580
      WEBKIT_DISABLE_COMPOSITING_MODE = "1";
    };
  };

  # Add programs available for all users.
  programs = {
    command-not-found.enable = true;
    fish.enable = true;
    steam.enable = true;
  };

  # Enable system-wide services.
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      layout = "se";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
    };
    flatpak.enable = true;
    openssh.enable = false;
    plex.enable = false;
    printing.enable = false;
    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
  };

  # Enable Docker container runtime.
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  # Auto-update system packages periodically.
  system.autoUpgrade = {
    enable = true;
    flake = "nixpkgs";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
