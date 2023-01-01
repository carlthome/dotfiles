{ config, pkgs, ... }: {
  home.username = "carl";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/carl" else "/home/carl";
  programs.git.userEmail = "carlthome@gmail.com";
}
