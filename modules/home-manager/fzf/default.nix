{
  config,
  pkgs,
  lib,
  self,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  fzfFunctions = {
    fzf-rg = {
      cmd = lib.getExe self.packages.${system}.fzf-ripgrep;
      zshKey = "^F";
      bashKey = "\\C-f";
    };
    fzf-open = {
      cmd = lib.getExe self.packages.${system}.fzf-open;
      zshKey = "^P";
      bashKey = "\\C-p";
    };
    fzf-git = {
      cmd = lib.getExe self.packages.${system}.fzf-gitgrep;
      zshKey = "^G";
      bashKey = "\\C-g";
    };
  };

  zshInit = builtins.concatStringsSep "\n\n" (
    builtins.attrValues (
      builtins.mapAttrs (
        name:
        { cmd, zshKey, ... }:
        ''
          ${name}() {
            ${cmd} "$BUFFER"
            zle reset-prompt
          }
          zle -N ${name}
          bindkey '${zshKey}' ${name}
        ''
      ) fzfFunctions
    )
  );

  bashInit = builtins.concatStringsSep "\n\n" (
    builtins.attrValues (
      builtins.mapAttrs (
        name:
        { cmd, bashKey, ... }:
        ''
          ${name}() {
            ${cmd} "$READLINE_LINE"
          }
          bind -x '"${bashKey}":${name}'
        ''
      ) fzfFunctions
    )
  );
in
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
  ];

  home.shellAliases = {
    "." = lib.getExe self.packages.${system}.fzf-open;
  };

  programs.zsh.initContent = zshInit;
  programs.bash.initExtra = bashInit;
}
