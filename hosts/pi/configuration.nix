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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJmEWvLXWvMV9S6XZApJUEaUPvTpEhPMiVWu7lZAEpQ"
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
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
      tmpfsSize = "1G";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/var/lib/prometheus2/data" = {
      fsType = "tmpfs";
      options = [ "size=1G" ];
    };

    "/var/lib/jellyfin/transcodes" = {
      fsType = "tmpfs";
      options = [ "size=1G" ];
    };

    "/mnt/datasets" = {
      device = "/dev/disk/by-uuid/1409bcc2-5b89-4d7e-ac96-c1db331053d8";
      fsType = "btrfs";
      options = [ "nofail" "compress=zstd" "subvol=datasets" ];
    };

    "/mnt/media" = {
      device = "/dev/disk/by-uuid/1409bcc2-5b89-4d7e-ac96-c1db331053d8";
      fsType = "btrfs";
      options = [ "nofail" "subvol=media" ];
    };
  };

  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
  };

  services.journald.storage = "volatile";

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [
      "/mnt/datasets"
      "/mnt/media"
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query"
      ];
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };
      blocking = {
        blackLists = {
          ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
        };
        clientGroupsBlock = {
          default = [ "ads" ];
        };
      };
    };
  };

  services.loki = {
    enable = true;
    configFile = ./loki/config.yml;
  };

  systemd.services.promtail = {
    description = "Promtail service for Loki";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.grafana-loki}/bin/promtail --config.file ${./loki/promtail.yml}
      '';
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "localhost";
      };
    };
    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
    ];
    provision.enable = true;
    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:${toString config.services.prometheus.port}";
        isDefault = true;
      }
      {
        name = "Loki";
        type = "loki";
        access = "proxy";
        url = "http://127.0.0.1:3100";
      }
      {
        name = "Blocky";
        type = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:4000";
      }
    ];
    provision.dashboards.settings.providers = [
      {
        name = "My Dashboards";
        options.path = "/etc/grafana/dashboards";
      }
    ];
  };

  services.prometheus = {
    enable = true;
    globalConfig = {
      scrape_interval = "15s";
      scrape_timeout = "10s";
      evaluation_interval = "15s";
    };
    scrapeConfigs = [
      {
        job_name = "node_exporter";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            "192.168.0.71:9100"
          ];
        }];
      }
      {
        job_name = "blocky";
        static_configs = [{
          targets = [
            "127.0.0.1:4000"
          ];
        }];
      }
    ];
    ruleFiles = [ ./prometheus/rules.yml ];
    alertmanagers = [{
      scheme = "http";
      path_prefix = "";
      static_configs = [{
        targets = [
          "127.0.0.1:${toString config.services.prometheus.alertmanager.port}"
        ];
      }];
    }];
  };

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" "processes" ];
  };

  services.prometheus.exporters.systemd = {
    enable = true;
  };

  services.prometheus.alertmanager = {
    enable = true;
    configText = builtins.readFile ./prometheus/alertmanager/config.yml;
    environmentFile = "/etc/nixos/secrets/alertmanager.env";
    checkConfig = false;
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.home-assistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    ports = [ "8123:8123" ];
    volumes = [
      "/etc/home-assistant:/config"
      "/etc/localtime:/etc/localtime:ro"
      "/run/dbus:/run/dbus:ro"
    ];
    extraOptions = [
      "--network=host"
      "--privileged"
    ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/datasets 192.168.0.19(rw,sync)
    /mnt/media 192.168.0.19(rw,sync)
  '';

  # Add all Grafana dashboards and Alertmanager templates to /etc.
  environment.etc =
    let
      dashboards = lib.mapAttrs'
        (name: value: lib.nameValuePair ("grafana/dashboards/" + name) {
          source = ./grafana/dashboards/${name};
          group = "grafana";
          user = "grafana";
        })
        (builtins.readDir ./grafana/dashboards);
      templates = lib.mapAttrs'
        (name: value: lib.nameValuePair ("alertmanager/templates/" + name) {
          source = ./prometheus/alertmanager/templates/${name};
          group = "grafana";
          user = "grafana";
        })
        (builtins.readDir ./prometheus/alertmanager/templates);
    in
    dashboards // templates;

  services.nginx = {
    enable = false; # TODO
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    upstreams = {
      "grafana" = {
        servers = {
          "127.0.0.1:${toString config.services.grafana.port}" = { };
        };
      };
      "prometheus" = {
        servers = {
          "127.0.0.1:${toString config.services.prometheus.port}" = { };
        };
      };
      "loki" = {
        servers = {
          "127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}" = { };
        };
      };
      "promtail" = {
        servers = {
          "127.0.0.1:${toString config.services.promtail.configuration.server.http_listen_port}" = { };
        };
      };
    };

    virtualHosts.grafana = {
      locations."/" = {
        proxyPass = "http://grafana";
        proxyWebsockets = true;
      };
      listen = [{
        addr = "192.168.0.75";
        port = 8010;
      }];
    };

    virtualHosts.prometheus = {
      locations."/".proxyPass = "http://prometheus";
      listen = [{
        addr = "192.168.0.75";
        port = 8020;
      }];
    };

    virtualHosts.loki = {
      locations."/".proxyPass = "http://loki";
      listen = [{
        addr = "192.168.0.75";
        port = 8030;
      }];
    };

    virtualHosts.promtail = {
      locations."/".proxyPass = "http://promtail";
      listen = [{
        addr = "192.168.0.75";
        port = 8031;
      }];
    };
  };

  networking.firewall.allowedTCPPorts = [
    #config.services.grafana.settings.server.http_port
    #config.services.prometheus.port
    #config.services.prometheus.alertmanager.port
    # TODO Expose Loki after adding authentication.
    #3100 # Loki
    #8123 # Home Assistant
    #2049 # NFS
  ];

  networking.firewall.allowedUDPPorts = [
    #53 # DNS
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
