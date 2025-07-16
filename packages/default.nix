{
  nixpkgs,
  mirpkgs,
  cargo2nix,
  system,
  ...
}@inputs:
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      mirpkgs.overlays.default
      cargo2nix.overlays.default
    ];
  };
  names = builtins.attrNames (
    nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.)
  );
  mkPackage = name: pkgs.callPackage ./${name} inputs;
  packages = nixpkgs.lib.genAttrs names mkPackage;
  allPackages =
    packages:
    pkgs.symlinkJoin {
      name = "update-and-switch";
      paths = (builtins.attrValues packages);
    };
in
packages // { default = allPackages packages; }
