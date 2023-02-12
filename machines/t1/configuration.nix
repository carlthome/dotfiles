{ config, pkgs, ... }: {
  networking.hostName = "t1";

  nixpkgs.config = {
    cudaSupport = true;
    cudnnSupport = true;
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
    cudaPackages.cudnn
  ];

  environment.sessionVariables = with pkgs; {
    LD_LIBRARY_PATH = "${cudaPackages.cudnn}/lib:${cudatoolkit}/lib:${cudatoolkit.lib}/lib:$LD_LIBRARY_PATH";
  };
}
