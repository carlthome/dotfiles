{ config, pkgs, ... }: {
  nixpkgs.config = {
    cudaSupport = true;
    cudnnSupport = true;
    allowUnfree = true;
    allowUnfreePredicate = pkg: true;
  };

  home.packages = with pkgs; [
    cudatoolkit
    cudaPackages.cudnn
    stdenv.cc.cc.lib
  ];

  home.sessionVariables = with pkgs; {
    LD_LIBRARY_PATH = "${stdenv.cc.cc.lib}/lib:${cudaPackages.cudnn}/lib:${cudatoolkit}/lib:$LD_LIBRARY_PATH";
  };
}
