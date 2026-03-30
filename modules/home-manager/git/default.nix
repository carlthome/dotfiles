{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  allowedSigners = [
    (self + /systems/mba/carl.pub)
    (self + /systems/t1/carl.pub)
  ];
in
{
  home.file.".ssh/allowed_signers".text = lib.concatMapStrings (
    path: "${config.programs.git.settings.user.email} ${builtins.readFile path}"
  ) allowedSigners;

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ed25519";
    };
    lfs = {
      enable = true;
      skipSmudge = false;
    };
    ignores = [
      ".DS_Store"
      "*~"
      "*.swp"
      ".venv"
      ".worktrees"
    ];
    settings = {
      aliases = {
        ci = "commit";
        co = "checkout";
        s = "status";
        l = "log";
        b = "branch";
        d = "diff";
        find = "grep -w";
        refresh = "!${lib.getExe self.packages.${system}.git-refresh}";
        sync = "!git fetch origin main:main";
        w = "worktree";
      };
      branch.sort = "-committerdate";
      checkout.defaultRemote = "origin";
      column.ui = "auto";
      core.editor = "vim";
      core.fsmonitor = true;
      core.untrackedCache = true;
      diff.algorithm = "histogram";
      diff.guitool = "vscode";
      diff.tool = "vimdiff";
      difftool.prompt = false;
      difftool.vscode.cmd = "code --wait --diff $LOCAL $REMOTE";
      fetch.prune = true;
      fetch.writeCommitGraph = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      help.autocorrect = 30;
      init.defaultBranch = "main";
      log.date = "relative";
      merge.autostash = true;
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
      status.showStash = true;
      tag.gpgSign = true;
      tag.sort = "-version:refname";
      user.useConfigOnly = true;
    };
  };
}
