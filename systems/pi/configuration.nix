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

    defaultGateway = {
      address = "192.168.0.1";
      interface = "wlan0";
    };

    interfaces."wlan0" = {
      ipv4.addresses = [
        { address = "192.168.0.2"; prefixLength = 24; }
      ];
    };

    firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        53 # DNS
      ];
      allowedUDPPorts = [
        53 # DNS
        67 # DHCP server
        68 # DHCP client
      ];
    };
  };

  services.fail2ban = {
    enable = true;
    jails = {
      ssh-iptables = ''
        enabled = true
        filter = sshd
        maxretry = 3
        findtime = 600
        bantime = 3600
      '';
    };
  };

  users.users = {
    pi = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF242vreA7b28tHGdr979yTEqyfIMStXn3Gqlr8OjKcS"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJmEWvLXWvMV9S6XZApJUEaUPvTpEhPMiVWu7lZAEpQ"
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

  services.dnsmasq = {
    enable = true;
    settings = {
      dhcp-range = "192.168.0.3,192.168.0.99,24h";
      dhcp-option = [
        "option:router,192.168.0.1"
        "option:dns-server,192.168.0.2"
      ];
      domain = "home.local";
      dhcp-authoritative = true;
      dhcp-lease-max = 100;
      log-dhcp = true;
      port = 0; # Disables DNS service since Blocky will handle it
    };
  };

  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      ports.http = 4000;
      prometheus.enable = true;
      queryLog.type = "none";
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
          pi  IN  A  192.168.0.2

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
        http_addr = "127.0.0.1";
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

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" "processes" ];
      };
      systemd = {
        enable = true;
      };
    };

    alertmanager = {
      enable = true;
      configText = builtins.readFile ./prometheus/alertmanager/config.yml;
      environmentFile = "/etc/nixos/secrets/alertmanager.env";
      checkConfig = false;
    };
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

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/datasets t1.local(rw,sync,no_subtree_check,sec=sys,root_squash)
      /mnt/media t1.local(rw,sync,no_subtree_check,sec=sys,root_squash)
    '';
  };

  security.acme = {
    defaults.email = "c@rlth.me";
    acceptTerms = true;
  };

  systemd.services.nginx-self-signed = {
    description = "Generate self-signed certificates for nginx";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "nginx";
      User = "nginx";
      Group = "nginx";
    };
    script = ''
      if [ ! -f "$STATE_DIRECTORY/self-signed.key" ]; then
        ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
          -keyout "$STATE_DIRECTORY/self-signed.key" \
          -out "$STATE_DIRECTORY/self-signed.crt" \
          -subj "/CN=*.home/O=Home Lab/C=SE"
        chmod 400 "$STATE_DIRECTORY/self-signed.key"
        chmod 444 "$STATE_DIRECTORY/self-signed.crt"
      fi
    '';
  };

  services.nginx =
    let
      mkVirtualHost = (domain: port: {
        addSSL = true;
        enableACME = false;
        sslCertificate = "/var/lib/nginx/self-signed.crt";
        sslCertificateKey = "/var/lib/nginx/self-signed.key";
        extraConfig = ''
          ssl_stapling off;
          ssl_stapling_verify off;
        '';
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
      recommendedTlsSettings = true;

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
