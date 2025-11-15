{ lib
, stdenv
, python3
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "defter-scrolling";
  version = "0.8.0";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  propagatedBuildInputs = with python3.pkgs; [
    evdev
    pyudev
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install the main script
    install -Dm755 defter-scrolling $out/bin/defter-scrolling

    # Wrap the script to ensure Python dependencies are available
    wrapProgram $out/bin/defter-scrolling \
      --prefix PYTHONPATH : "${lib.makeSearchPath python3.sitePackages propagatedBuildInputs}"

    # Install configuration file
    install -Dm644 defter-scrolling.conf $out/etc/defter-scrolling.conf

    # Generate systemd service file directly (instead of using generate-service.sh)
    mkdir -p $out/lib/systemd/system
    cat > $out/lib/systemd/system/defter-scrolling.service << 'EOF'
[Unit]
Description=a better way of scrolling, for mice
After=multi-user.target
Documentation=https://github.com/makoConstruct/middle-good-scrolling

[Service]
Type=simple
ExecStart=$out/bin/defter-scrolling
Restart=on-failure
RestartSec=5s

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/dev/input /dev/uinput

[Install]
WantedBy=multi-user.target
EOF

    # Install systemd preset
    install -Dm644 80-defter-scrolling.preset $out/lib/systemd/system-preset/80-defter-scrolling.preset

    runHook postInstall
  '';

  meta = with lib; {
    description = "A better way of scrolling, for mice";
    longDescription = ''
      Makes it so that clicking your chosen mouse button and dragging anywhere
      on the page is like clicking and dragging the scrollbar handle.
      Supports horizontal/biaxial scrolling and is smoother than libinput's
      implementation.
    '';
    homepage = "https://github.com/makoConstruct/middle-good-scrolling";
    license = licenses.bsd0;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "defter-scrolling";
  };
}
