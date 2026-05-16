{
  qemu,
  fetchurl,
  fetchgit,
}:
let
  keycodemapdb = fetchgit {
    url = "https://gitlab.com/qemu-project/keycodemapdb.git";
    rev = "f5772a62ec52591ff6870b7e8ef32482371f22c6";
    hash = "sha256-EQrnBAXQhllbVCHpOsgREzYGncMUPEIoWFGnjo+hrH4=";
  };
  berkeley-softfloat-3 = fetchgit {
    url = "https://gitlab.com/qemu-project/berkeley-softfloat-3.git";
    rev = "b64af41c3276f97f0e181920400ee056b9c88037";
    hash = "sha256-Yflpx+mjU8mD5biClNpdmon24EHg4aWBZszbOur5VEA=";
  };
  base = qemu.override {
    hostCpuTargets = [ "arm-softmmu" ];
    guestAgentSupport = false;
    enableDocs = false;
    enableTools = false;
  };
in
base.overrideAttrs (old: {
  pname = "qemu-pebble";
  version = "10.1.5-pebble11";

  src = fetchurl {
    url = "https://github.com/coredevices/qemu/archive/refs/tags/v10.1.5-pebble11.tar.gz";
    hash = "sha256-HmBTCC3obdrOnwtHz9gDnzlcb4wAA4nQq29UPn7R7M8=";
  };

  patches = [ ];

  preConfigure =
    ''
      # Vendor subproject git wraps that the coredevices fork doesn't bundle
      chmod u+w subprojects
      cp -r ${keycodemapdb} subprojects/keycodemapdb
      cp -r ${berkeley-softfloat-3} subprojects/berkeley-softfloat-3
      chmod -R u+w subprojects/keycodemapdb subprojects/berkeley-softfloat-3
      # berkeley-softfloat-3 has no meson build files upstream; packagefiles supplies them
      cp subprojects/packagefiles/berkeley-softfloat-3/meson.build subprojects/berkeley-softfloat-3/
      cp subprojects/packagefiles/berkeley-softfloat-3/meson_options.txt subprojects/berkeley-softfloat-3/
      # fp tests require berkeley-testfloat-3 which we don't need
      substituteInPlace tests/meson.build --replace-fail "  subdir('fp')" ""
    ''
    + old.preConfigure;

  # nixpkgs postInstall symlinks qemu-system-x86_64 → qemu-kvm; we only built arm
  postInstall = ''
    mv $out/bin/qemu-system-arm $out/bin/qemu-pebble
  '';

  meta = old.meta // {
    homepage = "https://github.com/coredevices/qemu";
    description = "Fork of QEMU for Pebble watches";
    mainProgram = "qemu-pebble";
    platforms = [ "x86_64-linux" ];
  };
})
