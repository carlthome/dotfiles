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
  buildInputs =
    with pkgs;
    pkgs.lib.optionals pkgs.stdenv.isLinux [
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
      udev
    ];
  postInstall = ''
    cp -r resources $out/bin
  '';
}
