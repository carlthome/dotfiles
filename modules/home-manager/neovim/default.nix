{ config, pkgs, lib, ... }: {

  programs.nixvim = {
    enable = true;
    vimdiffAlias = true;
    globals.mapleader = ",";
    colorscheme = "tokyonight";
    plugins = {
      airline.enable = true;
      bufferline.enable = true;
      dap.enable = true;
      direnv.enable = true;
      edgy.enable = true;
      fugitive.enable = true;
      gitblame.enable = true;
      gitgutter.enable = true;
      goyo.enable = true;
      headlines.enable = true;
      jupytext.enable = true;
      neoscroll.enable = true;
      neotest.enable = true;
      nix-develop.enable = true;
      noice.enable = true;
      specs.enable = true;
      startify.enable = true;
      statuscol.enable = true;
      telescope.enable = true;
      treesitter.enable = true;
      trouble.enable = true;
      twilight.enable = true;
      virt-column.enable = true;
      which-key.enable = true;
      wilder.enable = true;
      wtf.enable = true;
      toggleterm = {
        enable = true;
        settings = {
          autochdir = true;
        };
      };
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          nixd.enable = true;
          ruff-lsp.enable = true;
        };
        keymaps.lspBuf = {
          "gd" = "definition";
          "gD" = "references";
          "gt" = "type_definition";
          "gi" = "implementation";
          "K" = "hover";
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins;  [
      ale
      ctrlp
      fidget-nvim
      nerdtree
      nvim-highlite
      nvim-pqf
      nvim-remote-containers
      nvim-test
      nvim-treesitter-context
      plenary-nvim
      scrollbar-nvim
      staline-nvim
      tabout-nvim
      telescope-asynctasks-nvim
      telescope-dap-nvim
      telescope-fzf-native-nvim
      tint-nvim
      todo-comments-nvim
      tokyonight-nvim
      triptych-nvim
      vim-nix
      whitespace-nvim
      winbar-nvim
      windows-nvim
    ];

    opts = {
      autochdir = true;
      autoindent = true;
      copyindent = true;
      expandtab = true;
      hlsearch = true;
      ignorecase = true;
      incsearch = true;
      lazyredraw = true;
      mouse = "a";
      number = true;
      redrawtime = 200;
      showcmd = true;
      showmatch = true;
      smartcase = true;
      splitbelow = true;
      splitright = true;
      swapfile = false;
      syntax = "on";
      termguicolors = true;
      undofile = true;
      wildmenu = true;
      wildmode = "longest:full,full";
      wildoptions = "pum";
    };

    keymaps = [
      {
        #CTRL-r in visual mode to search and replace
        mode = "v";
        key = "<C-r>";
        options.noremap = true;
        action = "hy:%s/<C-r>h//gc<left><left><left>";
      }
      {
        # Format file
        key = "<leader>fm";
        action = "<CMD>lua vim.lsp.buf.format()<CR>";
        options.desc = "Format the current buffer";
      }
      {
        # Use git
        mode = "n";
        key = "<leader>g";
        action = "+git";
      }
    ];
  };
}
