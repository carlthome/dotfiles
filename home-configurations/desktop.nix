{ config, pkgs, ... }: {
  home.username = "carl";
  home.homeDirectory = "/home/carl";

  # TODO Configure home desktop programs when I find the time.
  home.packages = with pkgs; [
    #reaper
    #tdesktop
    #steam
  ];
}
