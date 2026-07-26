{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    withRuby = false;
    withPython3 = false;

    # Prevent Home Manager from owning ~/.config/nvim/init.lua.
    sideloadInitLua = true;

    extraPackages = with pkgs; [
      bash-language-server
      nixd
    ];

    plugins = with pkgs.vimPlugins; [
      lualine-nvim
      bufferline-nvim
      nvim-dap
      direnv-vim
      edgy-nvim
      vim-fugitive
      git-blame-nvim
      vim-gitgutter
      goyo-vim
      headlines-nvim
      neoscroll-nvim
      neotest
      nix-develop-nvim
      noice-nvim
      vim-startify
      statuscol-nvim
      tagbar
      telescope-nvim
      nvim-treesitter.withAllGrammars
      trouble-nvim
      twilight-nvim
      virt-column-nvim
      nvim-web-devicons
      which-key-nvim
      wilder-nvim
      wtf-nvim
      toggleterm-nvim
      nvim-lspconfig

      nui-nvim
      nvim-nio
      nvim-notify

      ale
      ctrlp-vim
      fidget-nvim
      nerdtree
      nvim-highlite
      nvim-pqf
      plenary-nvim
      scrollbar-nvim
      tabout-nvim
      telescope-asynctasks-nvim
      telescope-dap-nvim
      telescope-fzf-native-nvim
      tint-nvim
      todo-comments-nvim
      tokyonight-nvim
      triptych-nvim
      vim-flog
      vim-nix
      whitespace-nvim
      windows-nvim
    ];
  };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
