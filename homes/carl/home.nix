{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.username = "carl";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/carl" else "/home/carl";
  programs.git.settings.user.name = "Carl Thomé";
  programs.git.settings.user.email = "carlthome@gmail.com";
  services.auto-upgrade = {
    enable = true;
    flake = "github:carlthome/dotfiles";
  };
}
