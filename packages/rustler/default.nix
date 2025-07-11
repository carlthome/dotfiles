{
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage {
  pname = "rustler";
  version = "0.1.0";
  src = ./.;
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = with pkgs; lib.optionals (!stdenv.isDarwin) [
    glib
    gtk3
    cairo
    pango
    gdk-pixbuf
    glibc
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXext
    xorg.libXinerama
    xorg.libXxf86vm
    xorg.libXrender
    xorg.libxcb
    xorg.libXau
    xorg.libXdmcp
    mesa
    alsa-lib
    dbus
    freetype
    fontconfig
    zlib
  ];
  postInstall = ''
    cp -r resources $out/bin
  '';
}