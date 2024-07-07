{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    fira-code
  ];
  programs.kitty = {
    enable = true;

    # https://sw.kovidgoyal.net/kitty/conf.html
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
    };

    # https://github.com/kovidgoyal/kitty-themes
    theme = "Slate";

    font = {
      name = "Maple Mono";
      size = 14;
    };
  };
}
