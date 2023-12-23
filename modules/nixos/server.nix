{ config, pkgs, ... }: {
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = false;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;
  users.mutableUsers = false;
  documentation.man.enable = false;
  nix.settings.cores = 1;
  nix.settings.max-jobs = 1;
}
