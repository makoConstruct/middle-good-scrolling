#!/bin/bash
# Generate systemd service file for defter-scrolling

if [ $# -lt 1 ]; then
    echo "Usage: $0 <binary_path>" >&2
    echo "Example: $0 /usr/bin/defter-scrolling" >&2
    exit 1
fi

BINARY_PATH="$1"

cat << EOF
[Unit]
Description=Middle Mouse Button Scroll Interceptor
After=multi-user.target
Documentation=https://github.com/makoConstruct/middle-good-scrolling

[Service]
Type=simple
ExecStart=${BINARY_PATH}
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
