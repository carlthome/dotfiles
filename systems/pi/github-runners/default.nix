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

  # Kept across restarts: the build tree and the Nix dev shell GC root. Per instance, because two
  # concurrent cargo builds cannot share a target dir — they would serialise on its lock.
  cacheDir = name: "${workRoot}/.cache/${name}";

  # Downloaded crate sources, shared by every instance. Cargo guards this with its own file lock, so
  # concurrent builds are safe here; what they briefly serialise on is the download, not compilation.
  # Sharing means a lockfile change costs one download for the machine instead of one per instance.
  cargoHome = "${workRoot}/.cache/cargo";
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

  # Bound both runners together, including builds delegated to nix-daemon. Weights
  # yield under contention; the quota leaves CPU headroom even during busy CI.
  # MemoryHigh starts reclaim before MemoryMax confines an OOM to this slice.
  systemd.slices.ci = {
    description = "CI runners, kept from starving the services this box exists for";
    sliceConfig = {
      CPUWeight = 10;
      CPUQuota = "150%";
      IOWeight = 10;
      MemoryHigh = "40%";
      MemoryMax = "50%";
      MemorySwapMax = 0;
      TasksMax = 1024;
    };
  };

  # These also apply to system rebuilds: DNS takes priority over all local builds.
  nix.settings.cores = lib.mkForce 1;
  nix.settings.max-jobs = lib.mkForce 1;

  # Regenerable build trees; keep them out of the weekly Drive backup.
  services.restic.backups.datasets.exclude = [ workRoot ];

  systemd.tmpfiles.rules = [
    "d ${workRoot} 0750 github-runner github-runner -"
    "d ${workRoot}/.cache 0750 github-runner github-runner -"
    "d ${cargoHome} 0750 github-runner github-runner -"
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
    serviceOverrides.ReadWritePaths = [
      (cacheDir name)
      cargoHome
    ];

    extraEnvironment = {
      CARGO_HOME = cargoHome;
      CARGO_TARGET_DIR = "${cacheDir name}/target";
      CI_CACHE_DIR = cacheDir name;

      # Avoid creating large worker pools only to throttle them at the slice.
      CARGO_BUILD_JOBS = "1";
      RUST_TEST_THREADS = "1";
      RAYON_NUM_THREADS = "1";
      LP_NUM_THREADS = "1";
      OMP_NUM_THREADS = "1";

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
        serviceConfig = {
          Slice = "ci.slice";
          Nice = 15;
          IOSchedulingClass = "idle";
          OOMScoreAdjust = 500;
        };
        requires = [ "xvfb.service" ];
        after = [ "xvfb.service" ];
      }
    ) githubRunners
    // {
      # A daemon build is not a child of the runner; explicitly share its budget.
      nix-daemon.serviceConfig = {
        Slice = "ci.slice";
        Nice = lib.mkForce 15;
        IOSchedulingClass = lib.mkForce "idle";
        OOMScoreAdjust = lib.mkForce 500;
      };

      # Virtual display for headless runs; reachable through its abstract socket.
      xvfb = {
        description = "Virtual X display for CI";
        serviceConfig = {
          ExecStart = "${pkgs.xorg-server}/bin/Xvfb :99 -screen 0 1280x720x24 -nolisten tcp";
          Slice = "ci.slice";
          DynamicUser = true;
          Restart = "on-failure";
        };
      };
    };
}
