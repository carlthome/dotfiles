{ config, pkgs, ... }: {
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = false;
  security.pam.enableSSHAgentAuth = true;
  users.mutableUsers = false;
  documentation.man.enable = false;
}
