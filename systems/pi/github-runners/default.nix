# Self-hosted GitHub Actions runners, one per entry in `githubRunners`.
#
# Hosted Actions minutes run out quickly on private repositories; a workflow sends a job here with
# `runs-on: [self-hosted, <repo>-pi]`. Adding a repository is one line below. See README.md.
{ lib, pkgs, ... }:

let
  # Instance name -> repository. The instance is the systemd unit, work dir and cache dir; the
  # repository decides the label and token file. Several instances may serve one repository so a
  # short job (a playtest) runs beside a long one (a test suite) instead of queueing behind it.
  githubRunners = {
    rustler-1 = "carlthome/rustler";
    rustler-2 = "carlthome/rustler";
  };

  # `rustler-1` and `rustler-2` both answer for `carlthome/rustler`.
  repoOf = repo: baseNameOf repo;

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
    name = "pi-${name}";

    # A fine-grained PAT (Administration: read and write), placed by hand; see README.md.
    # One token per repository, shared by its instances.
    tokenFile = "/etc/nixos/secrets/github-runner/${repoOf repo}.token";

    # Shared by every instance of a repository, so a job lands on whichever is free.
    extraLabels = [ "${repoOf repo}-pi" ];
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
