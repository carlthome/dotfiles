{
  config,
  pkgs,
  lib,
  self,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  fzf-rg = lib.getExe self.packages.${system}.fzf-ripgrep;

  fzf-preview =
    let
      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-preview.sh";
        hash = "sha256-DkoKSJtUfap13Y7u/WtShgZ3QBsrd1T938txoYZdRVI=";
        executable = true;
      };
    in
    pkgs.writeShellScriptBin "fzf-preview.sh" ''
      export PATH="${
        lib.makeBinPath [
          pkgs.bat
          pkgs.file
          pkgs.chafa
          pkgs.coreutils
        ]
      }:$PATH"
      exec ${src} "$@"
    '';

  # Define FZF options here so they can be exported in shell init (avoids session var caching)
  fzfDefaultOpts = [
    "--height 100%"
    "--style full"
    "--layout default"
  ];
  fzfCtrlTCommand = "fd --type f";
  fzfAltCCommand = "fd --type d";
  fzfCtrlTOpts = [
    "--preview '${lib.getExe fzf-preview} {}'"
    "--bind 'focus:transform-preview-label:echo {}'"
    "--bind '?:toggle-preview'"
  ];
  fzfAltCOpts = [
    "--preview 'tree -C {}'"
    "--bind 'focus:transform-preview-label:echo {}'"
    "--bind '?:toggle-preview'"
  ];
  fzfCtrlROpts = [
    "--preview 'echo {}'"
    "--preview-window hidden"
    "--bind '?:toggle-preview'"
  ];

  toOpts = lib.concatStringsSep " ";
in
{
  programs.fzf = {
    enable = true;
    tmux.enableShellIntegration = config.programs.tmux.enable;
    defaultOptions = fzfDefaultOpts;
    fileWidgetCommand = fzfCtrlTCommand;
    fileWidgetOptions = fzfCtrlTOpts;
    changeDirWidgetCommand = fzfAltCCommand;
    changeDirWidgetOptions = fzfAltCOpts;
    historyWidgetOptions = fzfCtrlROpts;
  };

  programs.zsh.initContent = ''
    export FZF_DEFAULT_OPTS="${toOpts fzfDefaultOpts}"
    export FZF_CTRL_T_COMMAND="${fzfCtrlTCommand}"
    export FZF_CTRL_T_OPTS="${toOpts fzfCtrlTOpts}"
    export FZF_ALT_C_COMMAND="${fzfAltCCommand}"
    export FZF_ALT_C_OPTS="${toOpts fzfAltCOpts}"
    export FZF_CTRL_R_OPTS="${toOpts fzfCtrlROpts}"

    fzf-rg() { ${fzf-rg} "$BUFFER"; zle reset-prompt; }
    zle -N fzf-rg
    bindkey '^F' fzf-rg
    source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh

  '';

  programs.bash.initExtra = ''
    export FZF_DEFAULT_OPTS="${toOpts fzfDefaultOpts}"
    export FZF_CTRL_T_COMMAND="${fzfCtrlTCommand}"
    export FZF_CTRL_T_OPTS="${toOpts fzfCtrlTOpts}"
    export FZF_ALT_C_COMMAND="${fzfAltCCommand}"
    export FZF_ALT_C_OPTS="${toOpts fzfAltCOpts}"
    export FZF_CTRL_R_OPTS="${toOpts fzfCtrlROpts}"

    fzf-rg() { ${fzf-rg} "$READLINE_LINE"; }
    bind -x '"\C-f":fzf-rg'
    source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh

  '';

  programs.fish.interactiveShellInit = ''
    set -gx FZF_DEFAULT_OPTS "${toOpts fzfDefaultOpts}"
    set -gx FZF_CTRL_T_COMMAND "${fzfCtrlTCommand}"
    set -gx FZF_CTRL_T_OPTS "${toOpts fzfCtrlTOpts}"
    set -gx FZF_ALT_C_COMMAND "${fzfAltCCommand}"
    set -gx FZF_ALT_C_OPTS "${toOpts fzfAltCOpts}"
    set -gx FZF_CTRL_R_OPTS "${toOpts fzfCtrlROpts}"

    function fzf-rg; ${fzf-rg} (commandline); commandline -f repaint; end
    bind \cf fzf-rg
    source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.fish

  '';

  home.packages = with pkgs; [
    fd
    ripgrep
    tree
  ];
}
