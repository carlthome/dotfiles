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
      init.defaultBranch = "main";
      pull.ff = "only";
      push.autoSetupRemote = true;
      user.useConfigOnly = true;
    };
  };
}
