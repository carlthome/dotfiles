{ config, pkgs, lib, ... }: {
  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number
      set cc=80
      set list
      set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»
      if &diff
        colorscheme blue
      endif
    '';
    plugins = with pkgs.vimPlugins;  [
      vim-nix
      telescope-nvim
      telescope-fzf-native-nvim
    ];
  };
}
