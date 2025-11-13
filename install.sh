#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: This script should NOT be run as root.${NC}"
    echo "Please run it as a normal user. It will ask for sudo when needed."
    exit 1
fi

echo "==================================="
echo "  Defter Scrolling - Installation  "
echo "==================================="
echo ""

# Check for systemd
if ! command -v systemctl &> /dev/null; then
    echo -e "${RED}Error: systemd is required but not found.${NC}"
    echo "This script currently only supports systemd-based distributions."
    exit 1
fi

# Check for Python
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}Error: Python is required but not found.${NC}"
    echo "Please install Python 3 first."
    exit 1
fi

# Determine which python command to use
if command -v python3 &> /dev/null; then
    PYTHON_CMD=python3
else
    PYTHON_CMD=python
fi

# Check Python version
PYTHON_VERSION=$($PYTHON_CMD -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo -e "${GREEN}✓${NC} Found Python $PYTHON_VERSION"

# Check for required Python modules
echo ""
echo "Checking Python dependencies..."
MISSING_DEPS=()

if ! $PYTHON_CMD -c "import evdev" 2>/dev/null; then
    MISSING_DEPS+=("python-evdev")
fi

if ! $PYTHON_CMD -c "import pyudev" 2>/dev/null; then
    MISSING_DEPS+=("python-pyudev")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Warning: Missing Python dependencies: ${MISSING_DEPS[*]}${NC}"
    echo ""
    echo "To install them, use one of the following commands based on your distribution:"
    echo ""
    echo "  Ubuntu/Debian:"
    echo "    sudo apt install python3-evdev python3-pyudev"
    echo ""
    echo "  Fedora:"
    echo "    sudo dnf install python3-evdev python3-pyudev"
    echo ""
    echo "  Arch:"
    echo "    sudo pacman -S python-evdev python-pyudev"
    echo ""
    echo "  Or using pip:"
    echo "    pip install --user evdev pyudev"
    echo ""
    read -p "Continue installation anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} All Python dependencies found"
fi

echo ""
echo "Installing files..."

# Install binary
echo -n "  - Installing binary to /usr/bin/... "
sudo install -Dm755 defter-scrolling /usr/bin/defter-scrolling
echo -e "${GREEN}✓${NC}"

# Install systemd service
echo -n "  - Installing systemd service... "
sudo install -Dm644 defter-scrolling.service /etc/systemd/system/defter-scrolling.service
echo -e "${GREEN}✓${NC}"

# Install config file (only if it doesn't exist)
if [ -f /etc/defter-scrolling.conf ]; then
    echo -e "  - Config file already exists at /etc/defter-scrolling.conf ${YELLOW}(skipping)${NC}"
else
    echo -n "  - Installing config file to /etc/... "
    sudo install -Dm644 defter-scrolling.conf /etc/defter-scrolling.conf
    echo -e "${GREEN}✓${NC}"
fi

# Reload systemd
echo -n "  - Reloading systemd daemon... "
sudo systemctl daemon-reload
echo -e "${GREEN}✓${NC}"

# Enable and start service
echo -n "  - Enabling and starting service... "
sudo systemctl enable --now defter-scrolling.service
echo -e "${GREEN}✓${NC}"

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""

# Check if service is running
if systemctl is-active --quiet defter-scrolling.service; then
    echo -e "${GREEN}✓${NC} defter-scrolling is now running!"
else
    echo -e "${YELLOW}⚠${NC} Service was installed but may not be running. Check status with:"
    echo "   ${YELLOW}systemctl status defter-scrolling${NC}"
fi

echo ""
echo "==================================="
echo "  Optional Configuration:"
echo "==================================="
echo ""
echo "1. To customize settings, copy the config file:"
echo "   ${YELLOW}cp /etc/defter-scrolling.conf ~/.config/defter-scrolling.conf${NC}"
echo "   Then edit ~/.config/defter-scrolling.conf"
echo ""
echo "2. After changing configuration, restart the service:"
echo "   ${YELLOW}sudo systemctl restart defter-scrolling${NC}"
echo ""
echo "3. Check the service status anytime:"
echo "   ${YELLOW}systemctl status defter-scrolling${NC}"
echo ""
echo "For more information, see: https://github.com/makoConstruct/middle-good-scrolling"
echo ""
