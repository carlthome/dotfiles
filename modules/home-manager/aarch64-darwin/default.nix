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

  # Make sure applications show up on cmd+space on macOS.
  home.activation = {
    copyApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      src="$genProfilePath/home-path/Applications/"
      dst="${config.home.homeDirectory}/Applications/Home Manager Trampolines"
      mkdir -p "$dst"
      ${pkgs.rsync}/bin/rsync --archive --checksum --chmod=-w --copy-unsafe-links --delete "$src" "$dst"
    '';
  };
}
