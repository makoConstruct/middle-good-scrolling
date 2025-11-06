# middle good scrolling

Hold middle mouse button and drag to scroll in any direction, fast. It's not like that middle click scrolling you may have encountered on windows, for instance, it's more like grabbing and dragging to scroll on mobile, but you can (and should) amplify the scroll speed so that it moves faster than a 1 to 1 drag gesture would. The default scroll speed (40) is delightfully high.

**Now written in Rust for minimal CPU overhead (~1-2% vs 15% in Python).**

## Installation

### Building from source (Arch Linux)

1. Install Rust toolchain:
```bash
sudo pacman -S rust
```

2. Clone this repository:
```bash
git clone https://github.com/makoConstruct/middle-good-scrolling.git
cd middle-good-scrolling
```

3. Build the package:
```bash
makepkg -si
```

4. Enable and start the service:
```bash
sudo systemctl enable --now middle-good-scrolling.service
```

### Manual installation (any Linux distro)

1. Install Rust and development dependencies:
```bash
# Arch/Manjaro
sudo pacman -S rust systemd-libs

# Ubuntu/Debian
sudo apt install cargo libudev-dev

# Fedora
sudo dnf install rust cargo systemd-devel
```

2. Build the project:
```bash
cargo build --release
```

3. Install the binary:
```bash
sudo cp target/release/middle-good-scrolling /usr/bin/
```

4. Install and enable the service:
```bash
sudo cp middle-good-scrolling.service /usr/lib/systemd/system/
sudo systemctl enable --now middle-good-scrolling.service
```

## Configuration

Configuration files are read in order of precedence:
1. `~/.config/middle-good-scrolling.conf` (per-user)
2. `/etc/middle-good-scrolling.conf` (system-wide)

Example (this is the default):

```ini
[Settings]
# Scroll speed multiplier
# Higher values = faster scrolling
scroll_speed = 40

# Invert scroll direction
# true = material scrolling (drag down to move the page contents down, which means scrolling up)
# false = vulgar scrolling (drag down to scroll down, which means moving the page contents up)
invert_scroll = true

# How far (in pixels) to drag before considering it an intentional scroll and blocking the middle click events
# Lower values = more sensitive. It's acceptable for this to be 1. It shouldn't be set to 0.
drag_hysteresis = 2
```

After changing configuration, restart the service:
```bash
sudo systemctl restart middle-good-scrolling.service
```

### Troubleshooting

**Service won't start:**
- Check that `/dev/uinput` exists (you may need to load the `uinput` module: `sudo modprobe uinput`)
- Check permissions on `/dev/input/*` devices
- View logs: `sudo journalctl -u middle-good-scrolling.service -f`

**Build fails:**
- Ensure you have `libudev-dev` (Ubuntu/Debian) or `systemd-libs` (Arch) installed
- Update Rust: `rustup update`

## Requirements

- Rust toolchain (for building)
- Linux with evdev support
- systemd (for service management)
- Access to `/dev/input` and `/dev/uinput`

## Performance

The Rust implementation uses **~1-2% CPU** during rapid mouse movements, compared to **~15% CPU** for the Python version. This makes it suitable for long-running daemon use with minimal system impact.
