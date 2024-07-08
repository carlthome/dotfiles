{ config, pkgs, lib, ... }: {
  programs.vim = {
    enable = true;
    packageConfigurable = pkgs.vim;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-fugitive
      vim-nix
      vim-startify
      ctrlp
    ];
    settings = {
      copyindent = true;
      ignorecase = true;
      mouse = "a";
      number = true;
      smartcase = true;
    };
    extraConfig = ''
      " Highlight matches as you type
      set incsearch
      set hlsearch

      " Show suggestions when tab-completing
      set wildmenu
      set wildmode=longest:full,full
      set wildoptions=pum

      " Set current directory to the one of the current file
      set autochdir

      " Create a new vertical split below instead of above the current one
      set splitbelow

      " Show command as it is being typed
      set showcmd

      " Highlight matching brackets when the cursor is over them
      set showmatch

      " Don't redraw when recording macros
      set lazyredraw
      set redrawtime=200

      " Configure file explorer
      let g:netrw_banner = 0
      let g:netrw_liststyle = 3

      " CTRL-r in visual mode to search and replace
      vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

    '';
  };
}
