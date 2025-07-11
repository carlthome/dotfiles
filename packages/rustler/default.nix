{
  pkgs,
  ...
}:

let
  platformDeps =
    if pkgs.stdenv.isDarwin then
      [

      ]
    else
      [
        pkgs.glib
        pkgs.gtk3
        pkgs.cairo
        pkgs.pango
        pkgs.gdk-pixbuf
        pkgs.glibc
        pkgs.xorg.libX11
        pkgs.xorg.libXcursor
        pkgs.xorg.libXrandr
        pkgs.xorg.libXi
        pkgs.xorg.libXext
        pkgs.xorg.libXinerama
        pkgs.xorg.libXxf86vm
        pkgs.xorg.libXrender
        pkgs.xorg.libxcb
        pkgs.xorg.libXau
        pkgs.xorg.libXdmcp
        pkgs.mesa
        pkgs.alsa-lib
        pkgs.dbus
        pkgs.freetype
        pkgs.fontconfig
        pkgs.zlib
      ];
in

pkgs.rustPlatform.buildRustPackage {
  pname = "rustler";
  version = "0.1.0";
  src = ./.;
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = platformDeps;
  postInstall = ''
    cp -r resources $out/bin
  '';
}