{ pkgs, ... }:
pkgs.mkShell {
  name = "pytorch";
  packages = [
    (pkgs.python3.withPackages (ps: with ps; [
      ipython
      matplotlib
      torch-bin
      torchaudio-bin
      torchvision-bin
    ]))
  ];
  shellHook = ''
    ipython --pylab
  '';
}
