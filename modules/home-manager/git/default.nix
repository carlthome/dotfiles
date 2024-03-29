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
    ];
    extraConfig = {
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      core.editor = "vim";
      core.fsmonitor = true;
      core.untrackedCache = true;
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
      rerere.enabled = true;
      user.useConfigOnly = true;
      fetch.writeCommitGraph = true;
      branch.sort = "-committerdate";
    };
  };
}
