{ config, pkgs, lib, ... }: {
  nix.settings.trusted-users = [ "root" "carl" ];

  networking.hostName = "pi";

  users.users = {
    carl = {
      isNormalUser = true;
      description = "Carl Thomé";
      extraGroups = [ "wheel" ];
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF242vreA7b28tHGdr979yTEqyfIMStXn3Gqlr8OjKcS"
      ];
    };
  };

  hardware.enableRedistributableFirmware = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 80;
        domain = "localhost";
      };
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "hosts";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            "192.168.0.19:9100"
            "192.168.0.71:9100"
            "192.168.0.75:9100"
          ];
        }];
      }
    ];
  };

  virtualisation.oci-containers.containers.home-assistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    volumes = [
      "/etc/home-assistant:/config"
      "/etc/localtime:/etc/localtime:ro"
    ];
    extraOptions = [
      "--network=host"
      "--privileged"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    80 # Grafana
    8123 # Home Assistant
    9001 # Prometheus
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
