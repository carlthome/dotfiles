{ config, pkgs, lib, ... }:

let
  grafanaDashboards = lib.mapAttrs'
    (name: value: lib.nameValuePair ("grafana/dashboards/" + name) {
      source = ./grafana/dashboards/${name};
      group = "grafana";
      user = "grafana";
    })
    (builtins.readDir ./grafana/dashboards);

  alertManagerTemplates = lib.mapAttrs'
    (name: value: lib.nameValuePair ("alertmanager/templates/" + name) {
      source = ./prometheus/alertmanager/templates/${name};
      group = "alertmanager";
      user = "alertmanager";
    })
    (builtins.readDir ./prometheus/alertmanager/templates);

  configFiles = {
    "home-assistant/configuration.yaml" = {
      source = ./home-assistant/configuration.yaml;
      group = "home-assistant";
      user = "home-assistant";
      mode = "0644";
    };
  };
in
{
  nix.settings.trusted-users = [ "root" "carl" ];

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

    "/var/cache/jellyfin/transcodes" = {
      fsType = "tmpfs";
      options = [ "size=2G" ];
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

  environment.etc = configFiles // grafanaDashboards // alertManagerTemplates;

  networking = {
    hostName = "pi";
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
    firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        53 # DNS
      ];
      allowedUDPPorts = [
        53 # DNS
      ];
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
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
      ports.http = 4000;
      prometheus.enable = true;
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

      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = true;
        zone = ''
          $ORIGIN home.
          $TTL 86400

          router  IN  A  192.168.0.1
          pi  IN  A  192.168.0.75

          grafana  IN  CNAME  pi
          alertmanager  IN  CNAME  pi
          prometheus  IN  CNAME  pi
          loki  IN  CNAME  pi
          jellyfin  IN  CNAME  pi
          home-assistant  IN  CNAME  pi
          blocky  IN  CNAME  pi
        '';
      };
    };
  };

  services.loki = {
    enable = true;
    configFile = ./loki/config.yml;
  };

  services.promtail = {
    enable = true;
    configFile = ./loki/promtail.yml;
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "localhost";
      };
      panels.disable_sanitize_html = true;
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
        uid = "prometheus";
      }
      {
        name = "Loki";
        type = "loki";
        access = "proxy";
        url = "http://127.0.0.1:3100";
        uid = "loki";
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
            "localhost:${toString config.services.prometheus.exporters.node.port}"
            "pi-zero.local:9100"
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
    image = "ghcr.io/home-assistant/home-assistant:2024.12.1";
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

  security.acme = {
    defaults.email = "c@rlth.me";
    acceptTerms = true;
  };

  services.nginx =
    let
      mkVirtualHost = (domain: port: {
        addSSL = false;
        enableACME = false;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
        };
      });
    in
    {
      enable = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      virtualHosts = builtins.mapAttrs mkVirtualHost {
        "grafana.home" = config.services.grafana.settings.server.http_port;
        "alertmanager.home" = config.services.prometheus.alertmanager.port;
        "prometheus.home" = config.services.prometheus.port;
        "loki.home" = 3100;
        "jellyfin.home" = 8096;
        "home-assistant.home" = 8123;
        "blocky.home" = 4000;
      };
    };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
