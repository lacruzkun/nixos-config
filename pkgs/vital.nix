
{ lib
, stdenv
, requireFile
, autoPatchelfHook
, alsa-lib
, freetype
, libglvnd
, xorg
}:

stdenv.mkDerivation {
  pname = "vital";
  version = "1.5.5-local";

  src = requireFile {
    name = "VitalInstaller.tar.gz";

    # Replace this with the hash you calculated.
    hash = "m6mfcGRpX8Eslypf115BsXzt1I0PBabFgvBjl+2UJwc=";

    message = ''
      Add the archive with:
      nix store add-file ~/nix-local/vital/VitalInstaller.tar.gz
    '';
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    freetype
    libglvnd
    stdenv.cc.cc.lib

    libice
    libsm
    libx11
    libxext
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a lib $out/

    runHook postInstall
  '';

  meta = {
    description = "Vital wavetable synthesizer plugins";
    homepage = "https://vital.audio/";
    platforms = lib.platforms.linux;
  };
}

