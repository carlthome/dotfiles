final: prev: {
  pdm = prev.pdm.overridePythonAttrs (old: {
    pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "installer" ];
    doCheck = false;
  });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (_: pyPrev: {

      resolvelib = pyPrev.resolvelib.overridePythonAttrs (_: {
        patches = [ ];
        doCheck = false;
      });

      pipx = pyPrev.pipx.overridePythonAttrs (_: {
        doCheck = false;
      });

      unearth = pyPrev.unearth.overridePythonAttrs (_: {
        doCheck = false;
      });

    })
  ];
}
