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
  ];

  home.sessionVariables = with pkgs; {
    LD_LIBRARY_PATH = "${cudaPackages.cudnn}/lib:${cudatoolkit}/lib:${cudatoolkit.lib}/lib:$LD_LIBRARY_PATH";
  };
}
