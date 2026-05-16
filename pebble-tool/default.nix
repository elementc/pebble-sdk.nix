{
  lib,
  fetchFromGitHub,
  python3Packages,
  nodejs,
  libpebble2,
  sourcemap,
  pypkjs,
  makeWrapper,
  stdenv,
  freetype,
  zlib,
  glib,
  pixman,
  dtc,
  SDL2,
}:
let
  library_path = lib.makeLibraryPath [
    freetype
    zlib
    glib
    pixman
    dtc
    stdenv.cc.cc.lib
    SDL2
  ];
in
python3Packages.buildPythonPackage rec {
  name = "pebble-tool";
  version = "5.0.35";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "pebble-tool";
    tag = "v${version}";
    hash = "sha256-quBDT7Sh14v7N47H1EVsvELT3Kb7Oo9CkKx/OfvOkFs=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3Packages.hatchling
  ];

  buildInputs = [
    nodejs
  ];

  propagatedBuildInputs = with python3Packages; [
    libpebble2
    httplib2
    oauth2client
    pillow
    progressbar2
    pyasn1
    pyasn1-modules
    pypng
    pyqrcode
    requests
    rsa
    pyserial
    six
    sourcemap
    websocket-client
    wheel
    colorama
    packaging
    pypkjs
    freetype-py
    google-auth
    google-auth-oauthlib
    websockify
    cobs
  ];

  # pebble-tool requires rsa 4.9.1.
  # This version does not exist on GitHub as the project was archived at 4.9,
  # it only exists on pypi with the only change being an added README
  # that notifies PyPi users that it's archived.
  postPatch = ''
    substituteInPlace pyproject.toml --replace "rsa>=4.9.1" "rsa==4.9"
  '';

  format = "pyproject";
  postFixup = ''
    wrapProgram $out/bin/pebble \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
      --prefix LD_LIBRARY_PATH : ${library_path} \
      --prefix DYLD_LIBRARY_PATH : ${library_path} \
      --set PHONESIM_PATH ${pypkjs}/bin/pypkjs
  '';

  meta = {
    homepage = "https://github.com/coredevices/pebble-tool";
    description = "Tool for interacting with the Pebble SDK";
    mainProgram = "pebble";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    license = lib.licenses.mit;
  };
}
