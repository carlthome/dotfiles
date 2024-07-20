{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    maple-mono
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
      tab_powerline_style = "angled";
    };

    keybindings = {
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
    };

    # https://github.com/kovidgoyal/kitty-themes
    theme = "Grape";

    font = {
      name = "Maple Mono";
      size = 14;
    };
  };
}
