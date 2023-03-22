{ config, pkgs, ... }: {
  networking.hostName = "t1";

  nix = {
    settings = {
      substituters = [
        "https://cuda-maintainers.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };
  };

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
