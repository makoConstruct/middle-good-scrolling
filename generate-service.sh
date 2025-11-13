#!/bin/bash
# Generate systemd service file for defter-scrolling

if [ $# -lt 2 ]; then
    echo "Usage: $0 <binary_path> <output_file>"
    echo "Example: $0 /usr/bin/defter-scrolling defter-scrolling.service"
    exit 1
fi

BINARY_PATH="$1"
OUTPUT_FILE="$2"

cat > "$OUTPUT_FILE" << 'EOF'
[Unit]
Description=Middle Mouse Button Scroll Interceptor
After=multi-user.target
Documentation=https://github.com/makoConstruct/middle-good-scrolling

[Service]
Type=simple
ExecStart=BINARY_PATH_PLACEHOLDER
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

# Replace the placeholder with the actual binary path
sed -i "s|ExecStart=BINARY_PATH_PLACEHOLDER|ExecStart=${BINARY_PATH}|" "$OUTPUT_FILE"

echo "Service file generated: $OUTPUT_FILE"
