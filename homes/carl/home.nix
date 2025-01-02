{ config, pkgs, lib, ... }: {
  home.username = "carl";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/carl" else "/home/carl";
  programs.git.userName = "Carl Thomé";
  programs.git.userEmail = "carlthome@gmail.com";
  services.auto-upgrade = {
    enable = true;
    flake = "github:carlthome/dotfiles";
  };
}
