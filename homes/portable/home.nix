{
  config,
  pkgs,
  lib,
  ...
}:
let
  # builtins.getEnv returns "" in pure/CI mode; provide valid fallbacks so the
  # config builds without --impure. On a real machine, pass --impure and these
  # will reflect the actual user.
  username = let u = builtins.getEnv "USER"; in if u != "" then u else "user";
  homeEnv = builtins.getEnv "HOME";
  homeDirectory = if homeEnv != "" then homeEnv else "/home/${username}";

  # Guard pathExists behind homeEnv check: Nix && is lazy, so pathExists is
  # never called in pure mode (where homeEnv == ""), avoiding restricted-access errors.
  gitEmailFile = "${homeDirectory}/.config/dotfiles/git-email";
  gitEmail =
    let
      fromFile =
        if homeEnv != "" && builtins.pathExists gitEmailFile then
          builtins.replaceStrings [ "\n" "\r" ] [ "" "" ] (builtins.readFile gitEmailFile)
        else
          "";
      fromEnv = builtins.getEnv "GIT_EMAIL";
    in
    if fromFile != "" then fromFile else if fromEnv != "" then fromEnv else "carlthome@gmail.com";
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
