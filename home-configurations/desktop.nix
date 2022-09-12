{ config, pkgs, lib, options, specialArgs, modulesPath }: {
  home.username = "carl";
  home.homeDirectory = "/home/carl";

  systemd.user.services.sunshine = {
    Unit.Description = "Sunshine Gamestream Server for Moonlight";
    Install.WantedBy = [ "graphical-session.target" ];
    Service.ExecStart = "/usr/bin/sunshine";
  };
}
