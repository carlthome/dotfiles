{ config, pkgs, lib, self, ... }: {
  imports = [
    self.homeModules.vscode
    self.homeModules.vim
    self.homeModules.neovim
    self.homeModules.emacs
    self.homeModules.git
  ];

  home.username = "carlthome";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/carlthome" else "/home/carlthome";
  programs.git.userName = "Carl Thomé";
  programs.git.userEmail = "carl.thome@epidemicsound.com";
}
