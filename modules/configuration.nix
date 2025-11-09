{ nixpkgs, ... }:
{
  # Configure the `nix` program itself.
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://carlthome.cachix.org"
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "carlthome.cachix.org-1:BHerYg0J5Qv/Yw/SsxqPBlTY+cttA9axEsmrK24R15w="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    cores = 0;
    max-jobs = "auto";
  };

  # Link old commands (nix-shell, nix-build, etc.) to use the same nixpkgs as the flake.
  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

  # Enable automatic garbage collection.
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
}
