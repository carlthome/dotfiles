{
  config,
  pkgs,
  self,
  ...
}:

let
  fzfFunctions = {
    fzf-rg = {
      cmd = "${self.packages.${pkgs.system}.fzf-ripgrep}/bin/fzf-ripgrep";
      zshKey = "^F";
      bashKey = "\\C-f";
    };
    fzf-open = {
      cmd = "${self.packages.${pkgs.system}.fzf-open}/bin/fzf-open";
      zshKey = "^P";
      bashKey = "\\C-p";
    };
    fzf-git = {
      cmd = "${self.packages.${pkgs.system}.fzf-gitgrep}/bin/fzf-gitgrep";
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
    "." = "${self.packages.${pkgs.system}.fzf-open}/bin/fzf-open";
  };

  programs.zsh.initContent = zshInit;
  programs.bash.initExtra = bashInit;
}
