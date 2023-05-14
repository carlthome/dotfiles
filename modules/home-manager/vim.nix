{ config, pkgs, lib, ... }: {
  programs.vim = {
    enable = true;
    packageConfigurable = pkgs.vim;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-fugitive
      vim-nix
      vim-startify
    ];
    settings = {
      copyindent = true;
      ignorecase = true;
      mouse = "a";
      number = true;
      smartcase = true;
    };
  };
}
