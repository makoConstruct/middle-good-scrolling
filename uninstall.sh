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

echo "====================================="
echo "  Defter Scrolling - Uninstallation  "
echo "====================================="
echo ""

# Confirm uninstallation
read -p "Are you sure you want to uninstall defter-scrolling? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""
echo "Uninstalling..."

# Stop and disable service
if systemctl is-active --quiet defter-scrolling.service 2>/dev/null; then
    echo -n "  - Stopping service... "
    sudo systemctl stop defter-scrolling.service
    echo -e "${GREEN}✓${NC}"
fi

if systemctl is-enabled --quiet defter-scrolling.service 2>/dev/null; then
    echo -n "  - Disabling service... "
    sudo systemctl disable defter-scrolling.service
    echo -e "${GREEN}✓${NC}"
fi

# Remove service file
if [ -f /etc/systemd/system/defter-scrolling.service ]; then
    echo -n "  - Removing systemd service... "
    sudo rm -f /etc/systemd/system/defter-scrolling.service
    echo -e "${GREEN}✓${NC}"
fi

# Remove binary
if [ -f /usr/local/bin/defter-scrolling ]; then
    echo -n "  - Removing binary... "
    sudo rm -f /usr/local/bin/defter-scrolling
    echo -e "${GREEN}✓${NC}"
fi

# Ask about config file
if [ -f /etc/defter-scrolling.conf ]; then
    echo ""
    read -p "Remove system config file /etc/defter-scrolling.conf? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -n "  - Removing config file... "
        sudo rm -f /etc/defter-scrolling.conf
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "  - Keeping config file ${YELLOW}(preserved)${NC}"
    fi
fi

# Check for user config
if [ -f ~/.config/defter-scrolling.conf ]; then
    echo ""
    read -p "Remove user config file ~/.config/defter-scrolling.conf? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -n "  - Removing user config... "
        rm -f ~/.config/defter-scrolling.conf
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "  - Keeping user config ${YELLOW}(preserved)${NC}"
    fi
fi

# Reload systemd
echo -n "  - Reloading systemd daemon... "
sudo systemctl daemon-reload
echo -e "${GREEN}✓${NC}"

echo ""
echo -e "${GREEN}Uninstallation complete!${NC}"
echo ""
