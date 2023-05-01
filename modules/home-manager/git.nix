{ config, pkgs, ... }: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
      l = "log";
    };
    lfs = {
      enable = true;
      skipSmudge = true;
    };
    extraConfig = {
      core.editor = "vim";
      diff.guitool = "vscode";
      diff.tool = "vimdiff";
      difftool.prompt = false;
      difftool.vscode.cmd = "code --wait --diff $LOCAL $REMOTE";
      help.autocorrect = 30;
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      merge.guitool = "vscode";
      merge.tool = "vimdiff";
      mergetool.prompt = false;
      mergetool.vscode.cmd = "code --wait $MERGED";
      pull.ff = "only";
      push.autoSetupRemote = true;
      user.useConfigOnly = true;
    };
  };
}
