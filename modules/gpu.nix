{ pkgs, ... }: {
  nixpkgs.config = {
    cudaSupport = true;
    cudnnSupport = true;
    allowUnfree = true;
    allowUnfreePredicate = pkg: true;
  };
}
