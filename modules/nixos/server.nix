{ config, pkgs, ... }:
{

  # Configure key-based remote SSH access.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = false;
  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # Insist all users are declaratively defined.
  users.mutableUsers = false;

  # Clear out the default user environment.
  environment.defaultPackages = [ ];

  # Skip installing documentation on the server.
  documentation.enable = false;
  documentation.doc.enable = false;
  documentation.info.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;

  # Skip the program that suggests installable software.
  programs.command-not-found.enable = false;

  # Disable desktop-specific functionality.
  xdg.autostart.enable = false;
  xdg.icons.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;
}
