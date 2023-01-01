{ pkgs, ... }: {
  home.username = "carlthome";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/carlthome" else "/home/carlthome";
  programs.git.userEmail = "carl.thome@epidemicsound.com";
}
