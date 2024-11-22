{ nixpkgs, ... }@inputs:
let
  names = builtins.attrNames (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  configuration = {
    # Configure the `nix` program itself.
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://carlthome.cachix.org"
        "https://numtide.cachix.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "carlthome.cachix.org-1:BHerYg0J5Qv/Yw/SsxqPBlTY+cttA9axEsmrK24R15w="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      auto-optimise-store = true;
      cores = 4;
      max-jobs = 1;
    };

    # Link old commands (nix-shell, nix-build, etc.) to use the same nixpkgs as the flake.
    nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

    # Enable automatic garbage collection.
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };
  args = inputs // { inherit configuration; };
  mkHost = name: import ./${name} args;
in
nixpkgs.lib.genAttrs names mkHost
