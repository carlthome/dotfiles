{ ... }:
{
  # Back up datasets to Google Drive.
  services.restic.backups.datasets = {
    repository = "rclone:gdrive:/Datasets";
    # TODO Populate secrets automatically.
    passwordFile = "/etc/nixos/secrets/restic/datasets";
    rcloneConfigFile = "/etc/nixos/secrets/restic/rclone.conf";
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
