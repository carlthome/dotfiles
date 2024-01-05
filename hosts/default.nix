{ nixpkgs, nix-darwin, self, ... }:
let
  configuration = {
    # Configure the `nix` program itself.
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://carlthome.cachix.org"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "carlthome.cachix.org-1:BHerYg0J5Qv/Yw/SsxqPBlTY+cttA9axEsmrK24R15w="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
      # TODO https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = true;
      cores = 1;
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
in
{
  t1 = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      configuration
      ./t1/configuration.nix
      ./t1/hardware-configuration.nix
      self.nixosModules.default
      self.nixosModules.desktop
      self.nixosModules.cuda
    ];
  };

  pi = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      configuration
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      { sdImage.compressImage = false; }
      { nixpkgs.overlays = [ self.overlays.modules-closure ]; }
      ./pi/configuration.nix
      ./pi/hardware-configuration.nix
      self.nixosModules.default
      self.nixosModules.server
    ];
  };

  mbp = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      configuration
      ./mbp/configuration.nix
      self.darwinModules.default
    ];
  };

  Betty = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      configuration
      ./Betty/configuration.nix
      self.darwinModules.default
    ];
  };
}
