# Self-hosted GitHub Actions runners on the Pi, one per repository in `githubRunners`.
#
# Hosted Actions minutes on private repositories run out quickly; a workflow sends a job here with
# `runs-on: [self-hosted, <name>-pi]`. To add a repository, run
# `./register-github-runner.sh <owner>/<repo>` from this directory: it adds the entry below,
# installs the token, deploys and waits for the runner to come online.
{ lib, pkgs, ... }:

let
  # Runner name -> GitHub repository. The name is used for the systemd unit
  # (github-runner-<name>), the token file, the work dir and the `<name>-pi` label.
  githubRunners = {
    rustler = "carlthome/rustler";
  };

  tokenDir = "/etc/nixos/secrets/github-runner";

  # Build trees are several GB, so keep them off the SD card. Each runner deletes everything in its
  # own work dir on every start, so these directories must be dedicated to the runners.
  workRoot = "/mnt/datasets/.github-runner";
in
{
  users.users.github-runner = {
    isSystemUser = true;
    group = "github-runner";
  };
  users.groups.github-runner = { };

  # Regenerable CI build trees; keep them out of the weekly Drive backup.
  services.restic.backups.datasets.exclude = [ workRoot ];

  systemd.tmpfiles.rules = [
    "d ${workRoot} 0750 github-runner github-runner -"
  ]
  ++ lib.mapAttrsToList (
    name: _: "d ${workRoot}/${name} 0750 github-runner github-runner -"
  ) githubRunners;

  # Each token is a fine-grained PAT with Administration: read and write on its repository, so
  # re-registration keeps working (a one-hour registration token breaks on the next config change).
  services.github-runners = lib.mapAttrs (name: repo: {
    enable = true;
    url = "https://github.com/${repo}";
    name = "pi";
    tokenFile = "${tokenDir}/${name}.token";
    extraLabels = [ "${name}-pi" ];
    replace = true;
    user = "github-runner";
    workDir = "${workRoot}/${name}";

    # Most jobs here build through `nix develop`.
    extraPackages = with pkgs; [
      nix
      git
    ];

    # Headless defaults, so GUI apps and games can run their tests on a machine with no screen,
    # GPU or sound card.
    extraEnvironment = {
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
