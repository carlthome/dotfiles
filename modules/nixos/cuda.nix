{
  config,
  pkgs,
  lib,
  ...
}:
{
  nix.settings.substituters = [
    "https://cuda-maintainers.cachix.org"
  ];

  nix.settings.trusted-public-keys = [
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  ];

  nixpkgs.config = {
    cudaSupport = true;
    cudnnSupport = true;
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "cuda-merged"
        "cuda_cuobjdump"
        "cuda_gdb"
        "cuda_nvcc"
        "cuda_nvdisasm"
        "cuda_nvprune"
        "cuda_cccl"
        "cuda_cudart"
        "cuda_cupti"
        "cuda_cuxxfilt"
        "cuda_nvml_dev"
        "cuda_nvrtc"
        "cuda_nvtx"
        "cuda_profiler_api"
        "cuda_sanitizer_api"
        "libcublas"
        "libcufft"
        "libcurand"
        "libcusolver"
        "libcusparse"
        "libnpp"
        "libnvjpeg"
        "libnvjitlink"
        "cudnn"
        "steam"
        "steam-unwrapped"
        "nvidia-settings"
      ];
  };

  hardware.nvidia.open = true;
  hardware.nvidia-container-toolkit.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  environment.systemPackages = with pkgs; [
    cudatoolkit
    cudaPackages.cudnn
  ];
}
