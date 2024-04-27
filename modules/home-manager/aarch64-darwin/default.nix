{ config, pkgs, lib, ... }: {
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "roomeqwizard"
      "terraform"
      "vscode"
    ];
  };

  home.packages = with pkgs; [
    colima
    net-news-wire
    rectangle
    roomeqwizard
    sequelpro
    stats
    iterm2
  ];
}
