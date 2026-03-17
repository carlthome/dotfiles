{ config, lib, ... }:
{
  # Back up datasets to a host-specific Google Drive repository.
  # Using per-host repository paths ensures multiple clients can run
  # concurrently without restic lock conflicts.
  services.restic.backups.datasets = {
    repository = "rclone:gdrive:/Backups/${config.networking.hostName}/datasets";
    # TODO Populate secrets automatically.
    passwordFile = "/etc/nixos/secrets/restic/datasets";
    rcloneConfigFile = "/etc/nixos/secrets/restic/rclone.conf";
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
