# Self-hosted GitHub Actions runners, one per repository in `githubRunners`.
#
# Hosted Actions minutes run out quickly on private repositories; a workflow sends a job here with
# `runs-on: [self-hosted, <name>-pi]`. Adding a repository is one line below. See README.md.
{ lib, pkgs, ... }:

let
  # Runner name -> repository. The name is the systemd unit, token file, work dir and label.
  githubRunners = {
    rustler = "carlthome/rustler";
  };

  # Wiped on every service start, so nothing worth keeping lives here.
  workRoot = "/mnt/datasets/.github-runner";

  # Kept across restarts: cargo's registry and target dir, and the Nix dev shell GC root.
  cacheDir = name: "${workRoot}/.cache/${name}";
in
{
  users.users.github-runner = {
    isSystemUser = true;
    group = "github-runner";
  };
  users.groups.github-runner = { };

  # The shared config re-asks every cache about every missing path; remember misses here instead.
  nix.settings.narinfo-cache-negative-ttl = lib.mkForce 3600;

  # Mesa at /run/opengl-driver: headless CI still needs a GL driver to render into Xvfb.
  hardware.graphics.enable = true;

  # Regenerable build trees; keep them out of the weekly Drive backup.
  services.restic.backups.datasets.exclude = [ workRoot ];

  systemd.tmpfiles.rules = [
    "d ${workRoot} 0750 github-runner github-runner -"
    "d ${workRoot}/.cache 0750 github-runner github-runner -"
  ]
  ++ lib.concatLists (
    lib.mapAttrsToList (name: _: [
      "d ${workRoot}/${name} 0750 github-runner github-runner -"
      "d ${cacheDir name} 0750 github-runner github-runner -"
    ]) githubRunners
  );

  services.github-runners = lib.mapAttrs (name: repo: {
    enable = true;
    url = "https://github.com/${repo}";
    name = "pi";

    # A fine-grained PAT (Administration: read and write), placed by hand; see README.md.
    tokenFile = "/etc/nixos/secrets/github-runner/${name}.token";

    extraLabels = [ "${name}-pi" ];
    replace = true;
    user = "github-runner";
    workDir = "${workRoot}/${name}";

    # Node 24 only: nixpkgs refuses the end-of-life Node 20 the runner uses for hashFiles(), so a
    # job routed here must not call it.

    # Most jobs build through `nix develop`.
    extraPackages = with pkgs; [
      nix
      git
    ];

    # Everything outside the work dir is read-only to the service.
    serviceOverrides.ReadWritePaths = [ (cacheDir name) ];

    extraEnvironment = {
      CARGO_HOME = "${cacheDir name}/cargo";
      CARGO_TARGET_DIR = "${cacheDir name}/target";
      CI_CACHE_DIR = cacheDir name;

      # Headless defaults: no screen, no GPU, no sound card.
      DISPLAY = ":99";
      WGPU_BACKEND = "gl";
      LIBGL_ALWAYS_SOFTWARE = "1";
      ALSA_CONFIG_PATH = "${pkgs.writeText "alsa-null.conf" ''
        <${pkgs.alsa-lib}/share/alsa/alsa.conf>
        pcm.!default {
          type null
        }
      ''}";
    };
  }) githubRunners;

  systemd.services =
    lib.mapAttrs' (
      name: _:
      lib.nameValuePair "github-runner-${name}" {
        # The work dir is on the automounted USB drive.
        unitConfig.RequiresMountsFor = [ "/mnt/datasets" ];
        requires = [ "xvfb.service" ];
        after = [ "xvfb.service" ];
      }
    ) githubRunners
    // {
      # Virtual display for headless runs; reachable through its abstract socket.
      xvfb = {
        description = "Virtual X display for CI";
        serviceConfig = {
          ExecStart = "${pkgs.xorg-server}/bin/Xvfb :99 -screen 0 1280x720x24 -nolisten tcp";
          DynamicUser = true;
          Restart = "on-failure";
        };
      };
    };
}
