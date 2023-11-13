{ config, pkgs, lib, self, ... }: {
  imports = [
    self.homeModules.vscode
    self.homeModules.vim
    self.homeModules.neovim
    self.homeModules.emacs
    self.homeModules.git
  ];

  home.username = "carl";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/carl" else "/home/carl";
  programs.git.userName = "Carl Thomé";
  programs.git.userEmail = "carlthome@gmail.com";
}
