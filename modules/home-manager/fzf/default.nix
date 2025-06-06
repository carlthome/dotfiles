{
  config,
  pkgs,
  self,
  ...
}:
{
  programs.fzf = {
    enable = true;
    tmux.enableShellIntegration = config.programs.tmux.enable;
    defaultOptions = [ "--height 100%" ];
    fileWidgetOptions = [
      "--preview 'stat {}'"
      "--preview-window noborder"
    ];
  };

  home.packages = with pkgs; [
    fzf-git-sh
    bat
    self.packages.${pkgs.system}.fzf-open
  ];

  #home.shellAliases = {
  #  "." = "${self.packages.${pkgs.system}.fzf-open}/bin/fzf-open";
  #};

  programs.zsh.initContent = ''
    fzf-rg() {
      ${self.packages.${pkgs.system}.fzf-ripgrep}/bin/fzf-ripgrep "$BUFFER"
      zle reset-prompt
    }
    zle -N fzf-rg
    bindkey '^F' fzf-rg

    fzf-open() {
      ${self.packages.${pkgs.system}.fzf-open}/bin/fzf-open "$BUFFER"
      zle reset-prompt
    }
    zle -N fzf-open
    bindkey '^P' fzf-open
  '';

  programs.bash.initExtra = ''
    fzf-rg() {
        ${self.packages.${pkgs.system}.fzf-ripgrep}/bin/fzf-ripgrep "$READLINE_LINE"
    }
    bind -x '"\C-f": fzf-rg'

    fzf-open() {
        ${self.packages.${pkgs.system}.fzf-open}/bin/fzf-open "$READLINE_LINE"
    }
    bind -x '"\C-p": fzf-open'
  '';
}
