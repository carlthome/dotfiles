{
  config,
  pkgs,
  lib,
  ...
}:
let
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";

  # Read work email from ~/.config/dotfiles/git-email if it exists,
  # then fall back to GIT_EMAIL env var, then personal email.
  gitEmailFile = "${homeDirectory}/.config/dotfiles/git-email";
  gitEmail =
    if builtins.pathExists gitEmailFile then
      builtins.replaceStrings [ "\n" "\r" ] [ "" "" ] (builtins.readFile gitEmailFile)
    else
      let
        env = builtins.getEnv "GIT_EMAIL";
      in
      if env != "" then env else "carlthome@gmail.com";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  programs.git.settings.user.name = "Carl Thomé";
  programs.git.settings.user.email = gitEmail;
  services.auto-upgrade = {
    enable = true;
    flake = "github:carlthome/dotfiles#portable";
    impure = true;
  };
}
