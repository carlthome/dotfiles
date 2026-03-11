{ config, pkgs, ... }:
{
  # Enable SSH daemon for remote access.
  services.openssh.enable = true;

  # Require SSH keys instead of passwords.
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = false;

  # Allow sudo via forwarded SSH agent instead of password.
  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;

  # Use memory-safe Rust implementation of sudo.
  security.sudo-rs.enable = true;

  # Require all users to be declared in configuration.
  users.mutableUsers = false;

  # Remove default packages like nano and perl.
  environment.defaultPackages = [ ];

  # Skip man pages and other documentation.
  documentation.enable = false;
  documentation.doc.enable = false;
  documentation.info.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;

  # Disable "command not found" package suggestions.
  programs.command-not-found.enable = false;

  # Skip desktop environment integrations.
  xdg.autostart.enable = false;
  xdg.icons.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;
}
