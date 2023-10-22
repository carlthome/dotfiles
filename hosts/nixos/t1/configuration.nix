{ config, pkgs, ... }: {
  networking.hostName = "t1";

  users.users.carl = {
    isNormalUser = true;
    description = "Carl Thomé";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
  };

  nix.settings.substituters = [
    "https://cuda-maintainers.cachix.org"
    "https://nixpkgs-unfree.cachix.org"
    "https://numtide.cachix.org"
    "https://carlthome.cachix.org"
  ];

  nix.settings.trusted-public-keys = [
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    "carlthome.cachix.org-1:BHerYg0J5Qv/Yw/SsxqPBlTY+cttA9axEsmrK24R15w="
  ];

  nixpkgs.config = {
    cudaSupport = true;
    cudnnSupport = true;
    allowUnfree = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
    cudaPackages.cudnn
  ];

  environment.sessionVariables = with pkgs; {
    LD_LIBRARY_PATH = "${cudaPackages.cudnn}/lib:${cudatoolkit}/lib:${cudatoolkit.lib}/lib:$LD_LIBRARY_PATH";
  };

  networking.extraHosts = ''
    127.0.0.1 kubernetes.default.svc.cluster.local
  '';

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
            "192.168.0.71:9100"
          ];
        }];
      }
    ];
  };

  # Enable container runtime.
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  # Set up Home Assistant within a container.
  virtualisation.oci-containers.containers = {
    home-assistant = {
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
  };

  # Grafana and Home Assistant
  networking.firewall.allowedTCPPorts = [ 80 8123 9001 ];
}
