{ config, pkgs, lib, options, specialArgs, modulesPath }: {
  nixpkgs.config = {
    cudaSupport = true;
    cudnnSupport = true;
  };
}
