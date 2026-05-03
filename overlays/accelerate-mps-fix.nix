# Fix accelerate tests failing on macOS CI runners with limited GPU memory
final: prev: {
  python3Packages = prev.python3Packages.override {
    overrides = pfinal: pprev: {
      accelerate = pprev.accelerate.overridePythonAttrs (old: {
        preCheck = (old.preCheck or "") + ''
          # Disable MPS memory limit on CI runners with limited GPU memory
          export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0
        '';
      });
    };
  };
}
