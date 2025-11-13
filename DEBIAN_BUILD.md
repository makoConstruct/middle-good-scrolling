# Building the Debian Package

This document explains how to build the Debian/Ubuntu package for defter-scrolling.

## Prerequisites

Install the required build tools:

```bash
# On Debian/Ubuntu
sudo apt install debhelper devscripts build-essential
```

## Building the Package

From the repository root directory:

```bash
# Build binary package
dpkg-buildpackage -b -us -uc

# Or build both source and binary packages
dpkg-buildpackage -us -uc
```

The `.deb` package will be created in the parent directory (`../`).

## Installing the Package

```bash
# Install the built package
sudo dpkg -i ../defter-scrolling_0.8.0-1_all.deb

# Install any missing dependencies
sudo apt install -f
```

The package will:
- Install the binary to `/usr/bin/defter-scrolling`
- Install the systemd service to `/lib/systemd/system/defter-scrolling.service`
- Install the default config to `/etc/defter-scrolling.conf`
- Install the systemd preset to `/lib/systemd/system-preset/80-defter-scrolling.preset`
- Automatically enable and start the service

## Package Compatibility

Yes! Debian packages (`.deb`) are fully compatible with Ubuntu and all Ubuntu-based distributions (Linux Mint, Pop!_OS, elementary OS, etc.) since Ubuntu is based on Debian and uses the same package management system (dpkg/apt).

The package is built for `all` architectures since it's a Python script, so it will work on:
- amd64 (x86_64)
- i386 (32-bit x86)
- arm64 (ARM 64-bit)
- armhf (ARM 32-bit)
- And any other architecture supported by Debian/Ubuntu

## Uninstalling

```bash
sudo apt remove defter-scrolling

# Or to remove including configuration files
sudo apt purge defter-scrolling
```

## Building from a Clean Source

If you want to build from a release tarball:

```bash
# Extract the source
tar xzf defter-scrolling_0.8.0.orig.tar.gz
cd defter-scrolling-0.8.0/

# Build
dpkg-buildpackage -b -us -uc
```

## Troubleshooting

**Q: Build fails with "Unmet build dependencies"**
A: Install debhelper: `sudo apt install debhelper`

**Q: Build fails with "dh: command not found"**
A: Install the debhelper package: `sudo apt install debhelper`

**Q: Runtime errors about missing Python modules**
A: Install dependencies: `sudo apt install python3-evdev python3-pyudev`

## Package Metadata

- **Package name**: defter-scrolling
- **Version**: 0.8.0-1
- **Architecture**: all
- **Section**: utils
- **Priority**: optional
- **License**: 0BSD
