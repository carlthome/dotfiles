{
  config,
  pkgs,
  lib,
  ...
}:

let
  usbMount = subvol: extraOptions: {
    device = "/dev/disk/by-uuid/1409bcc2-5b89-4d7e-ac96-c1db331053d8";
    fsType = "btrfs";
    options = extraOptions ++ [
      "noauto"
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=30s"
      "x-systemd.mount-timeout=30s"
      "subvol=${subvol}"
    ];
  };

  grafanaDashboards = lib.mapAttrs' (
    name: value:
    lib.nameValuePair ("grafana/dashboards/" + name) {
      source = ./grafana/dashboards/${name};
      group = "grafana";
      user = "grafana";
    }
  ) (builtins.readDir ./grafana/dashboards);

  alertManagerTemplates = lib.mapAttrs' (
    name: value:
    lib.nameValuePair ("alertmanager/templates/" + name) {
      source = ./prometheus/alertmanager/templates/${name};
      group = "alertmanager";
      user = "alertmanager";
    }
  ) (builtins.readDir ./prometheus/alertmanager/templates);

  configFiles = {
    "home-assistant/configuration.yaml" = {
      source = ./home-assistant/configuration.yaml;
      group = "home-assistant";
      user = "home-assistant";
      mode = "0644";
    };
    "home-assistant/automations.yaml" = {
      source = ./home-assistant/automations.yaml;
      group = "home-assistant";
      user = "home-assistant";
      mode = "0644";
    };
    "home-assistant/scripts.yaml" = {
      source = ./home-assistant/scripts.yaml;
      group = "home-assistant";
      user = "home-assistant";
      mode = "0644";
    };
    "home-assistant/scenes.yaml" = {
      source = ./home-assistant/scenes.yaml;
      group = "home-assistant";
      user = "home-assistant";
      mode = "0644";
    };
  };

in
{
  hardware.enableRedistributableFirmware = true;

  boot = {
    supportedFilesystems.zfs = lib.mkForce false;
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
      tmpfsSize = "2G";
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

    "/var/cache/jellyfin" = {
      fsType = "tmpfs";
      options = [ "size=2G" ];
    };

    "/mnt/datasets" = usbMount "datasets" [ "compress=zstd" ];
    "/mnt/media" = usbMount "media" [ ];
  };

  environment.etc = configFiles // grafanaDashboards // alertManagerTemplates;

  networking = {
    hostName = "pi";

    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      allowAuxiliaryImperativeNetworks = true;
    };

    networkmanager.enable = false;

    defaultGateway = {
      address = "192.168.0.1";
      interface = "wlan0";
    };

    interfaces."wlan0" = {
      ipv4.addresses = [
        {
          address = "192.168.0.2";
          prefixLength = 24;
        }
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
        5353 # mDNS
        2049 # NFS
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

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  services.tailscale.extraSetFlags = [
    "--advertise-routes=192.168.0.0/24"
  ];

  services.journald.storage = "volatile";

  # Automatically backup datasets and media to Google Drive.
  services.restic.backups = {
    datasets.paths = [ "/mnt/datasets" ];
    media = {
      repository = "rclone:gdrive:/Media";
      # TODO Populate secrets automatically.
      passwordFile = "/etc/nixos/secrets/restic/media";
      rcloneConfigFile = "/etc/nixos/secrets/restic/rclone.conf";
      paths = [ "/mnt/media" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };
  };

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

  systemd.services.blocky-zone = {
    before = [ "blocky.service" ];
    requiredBy = [ "blocky.service" ];
    after = [
      "tailscaled.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    path = [ pkgs.tailscale ];
    script = ''
      ip=$(tailscale ip -4)
      [[ $ip =~ ^100\. ]] || exit 1
      mkdir -p /var/lib/blocky
      echo "@ IN A $ip" > /var/lib/blocky/tailscale.zone
      chmod 644 /var/lib/blocky/tailscale.zone
    '';
  };

  services.blocky = {
    enable = true;
    enableConfigCheck = false;
    settings = {
      ports.dns = 53;
      ports.http = 4000;
      prometheus.enable = true;
      queryLog.type = "none";
      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query"
      ];
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
      blocking = {
        blackLists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/multi.txt"
            "https://big.oisd.nl/domainswild"
            "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"
            "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
            "https://urlhaus.abuse.ch/downloads/hostfile/"
          ];
        };
        clientGroupsBlock = {
          default = [ "ads" ];
        };
      };

      conditional = {
        mapping = {
          "ts.net" = "100.100.100.100";
        };
      };

      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = true;
        zone = ''
          $ORIGIN home.
          $TTL 86400
          $INCLUDE /var/lib/blocky/tailscale.zone
          pi  IN  CNAME  @
          www  IN  CNAME  @
          grafana  IN  CNAME  @
          uptime-kuma  IN  CNAME  @
          alertmanager  IN  CNAME  @
          prometheus  IN  CNAME  @
          loki  IN  CNAME  @
          jellyfin  IN  CNAME  @
          home-assistant  IN  CNAME  @
          blocky  IN  CNAME  @
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
    # TODO https://github.com/NixOS/nixpkgs/blame/33b9d57c656e65a9c88c5f34e4eb00b83e2b0ca9/nixos/modules/services/logging/promtail.nix#L9
    configuration.scrape_configs = [ { journal = true; } ];
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
      analytics.reporting_enabled = false;
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
    listenAddress = "127.0.0.1";
    webExternalUrl = "https://prometheus.home";
    globalConfig = {
      scrape_interval = "15s";
      scrape_timeout = "10s";
      evaluation_interval = "15s";
    };
    scrapeConfigs = [
      {
        job_name = "node_exporter";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
              "pi-zero.local:9100"
              "t1:9100"
            ];
          }
        ];
      }
      {
        job_name = "blocky";
        static_configs = [
          {
            targets = [
              "127.0.0.1:4000"
            ];
          }
        ];
      }
    ];
    ruleFiles = [ ./prometheus/rules.yml ];
    alertmanagers = [
      {
        scheme = "http";
        path_prefix = "";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.alertmanager.port}"
            ];
          }
        ];
      }
    ];

    exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        enabledCollectors = [
          "systemd"
          "processes"
        ];
      };
      systemd = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
    };

    alertmanager = {
      enable = true;
      listenAddress = "127.0.0.1";
      webExternalUrl = "https://alertmanager.home";
      configText = builtins.readFile ./prometheus/alertmanager/config.yml;
      environmentFile = "/etc/nixos/secrets/alertmanager.env";
      checkConfig = false;
    };
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.home-assistant = {
    image = "ghcr.io/home-assistant/home-assistant:2024.12.1";
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

  security.sudo.wheelNeedsPassword = false;

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

  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = "8080";
    };
  };

  services.nginx =
    let
      services = {
        "grafana.home" = {
          port = config.services.grafana.settings.server.http_port;
          name = "Grafana";
          description = "Metrics dashboards";
        };
        "uptime-kuma.home" = {
          port = config.services.uptime-kuma.settings.PORT;
          name = "Uptime Kuma";
          description = "Service monitoring";
        };
        "prometheus.home" = {
          port = config.services.prometheus.port;
          name = "Prometheus";
          description = "Metrics database";
        };
        "alertmanager.home" = {
          port = config.services.prometheus.alertmanager.port;
          name = "Alertmanager";
          description = "Alert routing";
        };
        "loki.home" = {
          port = 3100;
          name = "Loki";
          description = "Log aggregation";
        };
        "jellyfin.home" = {
          port = 8096;
          name = "Jellyfin";
          description = "Media server";
        };
        "home-assistant.home" = {
          port = 8123;
          name = "Home Assistant";
          description = "Home automation";
        };
        "blocky.home" = {
          port = 4000;
          name = "Blocky";
          description = "DNS ad-blocking";
        };
      };

      mkServiceCard = domain: svc: ''
        <a href="https://${domain}" class="service-card">
          <h2>${svc.name}</h2>
          <p>${svc.description}</p>
          <div class="url">${domain}</div>
        </a>
      '';

      html =
        builtins.replaceStrings
          [ "{{SERVICES}}" ]
          [ (lib.concatStringsSep "\n" (lib.mapAttrsToList mkServiceCard services)) ]
          (builtins.readFile ./www/index.html);

      index = pkgs.writeTextDir "index.html" html;

      sslConfig = {
        addSSL = true;
        enableACME = false;
        sslCertificate = "/var/lib/nginx/self-signed.crt";
        sslCertificateKey = "/var/lib/nginx/self-signed.key";
        extraConfig = ''
          ssl_stapling off;
          ssl_stapling_verify off;
        '';
      };

      mkVirtualHost =
        domain: svc:
        sslConfig
        // {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString svc.port}";
            proxyWebsockets = true;
          };
        };

      wwwConfig = sslConfig // {
        root = index;
        locations."/" = {
          index = "index.html";
          tryFiles = "$uri $uri/ /index.html";
        };
      };
    in
    {
      enable = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedTlsSettings = true;

      virtualHosts = (lib.mapAttrs mkVirtualHost services) // {
        "www.home" = wwwConfig;
        "${config.networking.hostName}.home" = wwwConfig;
        "${config.networking.hostName}.local" = wwwConfig // {
          default = true;
        };
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
