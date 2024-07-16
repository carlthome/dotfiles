{ nixpkgs-unstable, mirpkgs, system, ... }@inputs:
let
  pkgs = import nixpkgs-unstable {
    inherit system; overlays = [ mirpkgs.overlays.default ];
    config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-unstable.lib.getName pkg) [
      "cuda_cccl"
      "cuda_cudart"
      "cuda_cupti"
      "cuda_nvcc"
      "cuda_nvrtc"
      "cuda_nvtx"
      "cudnn"
      "libcublas"
      "libcufft"
      "libcurand"
      "libcusolver"
      "libcusparse"
      "libnvjitlink"
      "torch"
      "triton"
    ];
  };
  names = builtins.attrNames (pkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
  mkPackage = name: pkgs.callPackage ./${name} inputs;
  packages = pkgs.lib.genAttrs names mkPackage;
  allPackages = packages: pkgs.symlinkJoin { name = "update-and-switch"; paths = (builtins.attrValues packages); };
in
packages // { default = allPackages packages; }
