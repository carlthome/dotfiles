{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
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
      };
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
