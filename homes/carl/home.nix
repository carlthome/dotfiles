{ config, pkgs, lib, self, ... }: {
  imports = with self.homeModules; [
    vscode
    vim
    neovim
    emacs
    git
    github
    tmux
    fzf
    auto-upgrade
    git-refresh
    auto-audit
    kitty
  ];

  home.username = "carl";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/carl" else "/home/carl";
  programs.git.userName = "Carl Thomé";
  programs.git.userEmail = "carlthome@gmail.com";
}
