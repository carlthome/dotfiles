{ pkgs, self, ... }:
{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        clone-all = "!${self.packages.${pkgs.system}.github-clone-all}/bin/github-clone-all";
        stats = "!${self.packages.${pkgs.system}.github-stats}/bin/github-stats";
      };
    };
    gitCredentialHelper.enable = false;
  };
}
