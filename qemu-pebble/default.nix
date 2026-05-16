{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  SDL2,
  glib,
  zlib,
  pixman,
  udev,
  alsa-lib,
  libpulseaudio,
  sndio,
  bzip2,
}:
stdenv.mkDerivation {
  pname = "qemu-pebble";
  version = "10.1.5-pebble5";

  src = fetchurl {
    url = "https://github.com/coredevices/qemu/releases/download/v10.1.5-pebble5/qemu-pebble-linux-x86_64.tar.gz";
    hash = "sha256-yo171+UUg7h57EuGlDbcPVwipF3N9PPDV/ajSaIDztw=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    SDL2
    glib
    zlib
    pixman
    udev
    alsa-lib
    libpulseaudio
    sndio
    bzip2.out
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp qemu-pebble $out/bin/
    chmod +x $out/bin/qemu-pebble
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/coredevices/qemu";
    description = "Fork of QEMU for Pebble watches (pre-built)";
    mainProgram = "qemu-pebble";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.gpl2Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
