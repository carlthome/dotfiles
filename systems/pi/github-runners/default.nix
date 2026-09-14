# Self-hosted GitHub Actions runners on the Pi, one per repository in `githubRunners`.
#
# Hosted Actions minutes on private repositories run out quickly; a workflow sends a job here with
# `runs-on: [self-hosted, <name>-pi]`. Adding a repository is one line below, and the Pi picks it up
# at its nightly auto-upgrade. The shared token is set up once; see README.md.
{ lib, pkgs, ... }:

let
  # Runner name -> GitHub repository. The name is used for the systemd unit
  # (github-runner-<name>), the token file, the work dir and the `<name>-pi` label.
  githubRunners = {
    rustler = "carlthome/rustler";
  };

  # Build trees are several GB, so keep them off the SD card. Each runner deletes everything in its
  # own work dir on every start, so these directories must be dedicated to the runners.
  workRoot = "/mnt/datasets/.github-runner";

  # Build state that should outlive a runner restart, which wipes the work dir: cargo's registry and
  # target dir, and the Nix dev shell GC root a workflow records in CI_CACHE_DIR. One per runner, next
  # to the work dirs rather than inside them (the dot keeps a runner named "cache" from landing on it),
  # and excluded from the backup along with the rest of workRoot.
  cacheDir = name: "${workRoot}/.cache/${name}";
in
{
  users.users.github-runner = {
    isSystemUser = true;
    group = "github-runner";
  };
  users.groups.github-runner = { };

  # The shared config never caches a binary-cache miss (negative TTL 0), so a CI build re-asks all
  # five caches about every path it has to build, thousands of lookups for a Rust dependency build.
  # Remember misses for an hour on this host only.
  nix.settings.narinfo-cache-negative-ttl = lib.mkForce 3600;

  # Regenerable CI build trees; keep them out of the weekly Drive backup.
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
    # A fine-grained PAT (Administration: read and write), placed by hand as a root-only file like the
    # other secrets in /etc/nixos/secrets; see README.md. A PAT rather than a registration token,
    # because registration tokens expire after an hour and break the next re-registration.
    tokenFile = "/etc/nixos/secrets/github-runner/${name}.token";
    extraLabels = [ "${name}-pi" ];
    replace = true;
    user = "github-runner";
    workDir = "${workRoot}/${name}";

    # Most jobs here build through `nix develop`.
    extraPackages = with pkgs; [
      nix
      git
    ];

    # Only the default Node 24 runtime: nixpkgs refuses the end-of-life Node 20. The runner still
    # evaluates hashFiles() with Node 20, so a job routed here must not use it (rustler's workflows
    # skip their hashFiles-keyed cache steps on self-hosted runners).

    # The service sandbox makes everything but the work dir read-only; the cache dir must be writable.
    serviceOverrides.ReadWritePaths = [ (cacheDir name) ];

    # Headless defaults, so GUI apps and games can run their tests on a machine with no screen,
    # GPU or sound card.
    extraEnvironment = {
      # Build state that survives runner restarts; see cacheDir above.
      CARGO_HOME = "${cacheDir name}/cargo";
      CARGO_TARGET_DIR = "${cacheDir name}/target";
      CI_CACHE_DIR = cacheDir name;

      DISPLAY = ":99";
      # Software GL. rustler's dev shell forces an NVIDIA Vulkan ICD, which doesn't exist here.
      WGPU_BACKEND = "gl";
      LIBGL_ALWAYS_SOFTWARE = "1";
      # Route ALSA's default PCM to null, as hosted runners are usually set up to do.
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
        # The work dir lives on the automounted USB drive.
        unitConfig.RequiresMountsFor = [ "/mnt/datasets" ];
        requires = [ "xvfb.service" ];
        after = [ "xvfb.service" ];
      }
    ) githubRunners
    // {
      # Virtual display for headless runs. Xvfb also listens on the abstract socket, which the
      # runners can reach despite their PrivateTmp sandbox.
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
