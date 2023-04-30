{ config, pkgs, lib, ... }: {
  programs.vim = {
    enable = true;
    packageConfigurable = pkgs.vim;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-nix
    ];
    settings = {
      ignorecase = true;
    };
    extraConfig = ''
      set mouse=a
    '';
  };
}
