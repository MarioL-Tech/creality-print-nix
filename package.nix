{
  lib,
  appimageTools,
  fetchurl,
  makeDesktopItem,
  useX11 ? false,
}:

let
  pname = "creality-print";
  version = "7.3.1";

  # Official stable release, not the newer upstream prerelease.
  src = fetchurl {
    url = "https://github.com/CrealityOfficial/CrealityPrint/releases/download/v${version}/CrealityPrint-V${version}.6378-x86_64-Release.AppImage";
    hash = "sha256-+Mjb8YprDVh4lhskSQ/CCVju/i8D9qifUky5sh5VoQc=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
    # AppRun otherwise hides the FHS environment's libraries from the app.
    postExtract = ''
      substituteInPlace "$out/AppRun" \
        --replace-fail 'export LD_LIBRARY_PATH="$DIR/bin:$DIR/usr/lib"' 'export LD_LIBRARY_PATH="$DIR/bin:$DIR/usr/lib:/usr/lib64"'
    '';
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Creality Print";
    comment = "Prepare models for Creality 3D printers";
    exec = "${pname} %F";
    icon = pname;
    categories = [ "Graphics" ];
    mimeTypes = [
      "model/stl"
      "application/vnd.ms-3mfdocument"
      "application/prs.wavefront-obj"
      "application/x-amf"
    ];
    terminal = false;
  };
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  # Work around fractional-scale rendering problems on affected desktops.
  profile = lib.optionalString useX11 ''
    export GDK_BACKEND=x11
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
  '';

  # These are linked by the binary but not supplied by appimageTools' defaults.
  extraPkgs = pkgs: [
    pkgs.libdeflate
    pkgs.libsoup_3
    pkgs.webkitgtk_4_1
    pkgs.zstd
  ];

  extraInstallCommands = ''
    install -Dm444 ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop
    install -Dm444 ${appimageContents}/.DirIcon \
      $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

  passthru = { inherit appimageContents; };

  meta = {
    description = "Creality's official 3D printing slicer";
    homepage = "https://github.com/CrealityOfficial/CrealityPrint";
    changelog = "https://github.com/CrealityOfficial/CrealityPrint/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
