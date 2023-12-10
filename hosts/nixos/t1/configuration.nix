{ config, pkgs, lib, ... }: {
  networking.hostName = "t1";

  users.users = {
    carl = {
      isNormalUser = true;
      description = "Carl Thomé";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      packages = with pkgs; [ ];
    };
  };

  networking.extraHosts = ''
    127.0.0.1 kubernetes.default.svc.cluster.local
  '';

  services.restic.backups = {
    datasets = {
      repository = "rclone:gdrive:/Datasets";
      # TODO Populate secrets automatically.
      passwordFile = "/etc/nixos/secrets/restic/datasets";
      rcloneConfigFile = "/etc/nixos/secrets/restic/rclone.conf";
      paths = [ "/usr/share/datasets" ];
      timerConfig = { OnCalendar = "weekly"; Persistent = true; };
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" ];
  };

  # Enable container runtime.
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # For running pre-compiled executables as per https://blog.thalheim.io/2022/12/31/nix-ld-a-clean-solution-for-issues-with-pre-compiled-executables-on-nixos/
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      zlib
      nss
      openssl
      curl
      expat
    ];
  };

  # Enable cross-platform emulator
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
