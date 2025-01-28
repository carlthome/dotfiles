{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      sensible
      resurrect
      continuum
    ];
    extraConfig = ''
      # Enable mouse mode.
      set-option -g mouse on

      # Automatic session restore.
      set -g @continuum-restore 'on'
    '';
  };
}
