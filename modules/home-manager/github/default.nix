{
  pkgs,
  lib,
  self,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        clone-all = "!${lib.getExe self.packages.${system}.github-clone-all}";
        stats = "!${lib.getExe self.packages.${system}.github-stats}";
        dashboard = "!${lib.getExe self.packages.${system}.github-actions-dashboard-creator}";
      };
    };
    gitCredentialHelper.enable = false;
  };
}
