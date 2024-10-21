{ config, pkgs, self, ... }: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
      l = "log";
      b = "branch";
      d = "diff";
      find = "grep -w";
      refresh = "!${self.packages.${pkgs.system}.git-refresh}/bin/git-refresh";
    };
    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ed25519";
    };
    lfs = {
      enable = true;
      skipSmudge = true;
    };
    ignores = [
      ".DS_Store"
      "*~"
      "*.swp"
      ".venv"
    ];
    extraConfig = {
      branch.sort = "-committerdate";
      core.editor = "vim";
      core.fsmonitor = true;
      core.untrackedCache = true;
      diff.guitool = "vscode";
      diff.tool = "vimdiff";
      difftool.prompt = false;
      difftool.vscode.cmd = "code --wait --diff $LOCAL $REMOTE";
      fetch.writeCommitGraph = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      help.autocorrect = 30;
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      merge.guitool = "vscode";
      merge.tool = "vimdiff";
      mergetool.prompt = false;
      mergetool.vscode.cmd = "code --wait $MERGED";
      pull.ff = "only";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autostash = true;
      rerere.enabled = true;
      user.useConfigOnly = true;
    };
  };
}
