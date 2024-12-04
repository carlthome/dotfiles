{ config, pkgs, lib, ... }: {

  programs.nixvim = {
    enable = true;
    vimdiffAlias = true;
    globals.mapleader = ",";
    colorscheme = "tokyonight";
    plugins = {
      lualine.enable = true;
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
      tagbar.enable = true;
      telescope.enable = true;
      treesitter.enable = true;
      trouble.enable = true;
      twilight.enable = true;
      virt-column.enable = true;
      web-devicons.enable = true;
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
          ruff_lsp.enable = true;
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
        mode = "n";
        key = "<F8>";
        action = ":TagbarToggle<CR>";
        options.desc = "Toggle Tagbar";
      }
      {
        mode = "v";
        key = "<C-r>";
        options.noremap = true;
        action = "hy:%s/<C-r>h//gc<left><left><left>";
        options.desc = "CTRL-r in visual mode to search and replace";
      }
      {
        key = "<leader>fm";
        action = "<CMD>lua vim.lsp.buf.format()<CR>";
        options.desc = "Format the current buffer";
      }
      {
        mode = "n";
        key = "<leader>g";
        action = "+git";
        options.desc = "Git";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = ":bprev<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = ":bnext<CR>";
        options.desc = "Next buffer";
      }
    ];
  };
}
