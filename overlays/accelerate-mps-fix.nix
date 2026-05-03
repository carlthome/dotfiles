final: prev: {
  python3Packages = prev.python3Packages.override {
    overrides = pfinal: pprev: {
      accelerate = pprev.accelerate.overridePythonAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [
          "test_mps"
        ];
      });
    };
  };
}
