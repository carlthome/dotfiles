{ config, pkgs, self, ... }: {
  programs.fzf = {
    enable = true;
    tmux.enableShellIntegration = config.programs.tmux.enable;
    defaultOptions = [ "--height 100%" "--layout=reverse" "--info=inline" "--border" "--margin=1" "--padding=1" ];
    fileWidgetOptions = [ "--preview 'stat {}'" ];
  };

  home.packages = with pkgs; [
    fzf-git-sh
    bat
    self.packages.${pkgs.system}.fzf-open
  ];

  #home.shellAliases = {
  #  "." = "${self.packages.${pkgs.system}.fzf-open}/bin/fzf-open";
  #};

  programs.zsh.initExtra = ''
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
