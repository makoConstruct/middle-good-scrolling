# middle good scrolling

Hold middle mouse button and drag to scroll in any direction, fast. It's not like that middle click scrolling you may have encountered on windows, for instance, it's more like grabbing and dragging to scroll on mobile, but you can (and should) amplify the scroll speed so that it moves faster than a 1 to 1 drag gesture would. The default scroll speed (40) is delightfully high.

## Installation

### Building from source (Arch Linux)

1. Clone this repository:
```bash
git clone https://github.com/makoConstruct/middle-good-scrolling.git
cd middle-good-scrolling
```

2. Build the package:
```bash
makepkg -si
```

3. Enable and start the service:
```bash
sudo systemctl enable --now middle-good-scrolling.service
```

### Manual installation

If you prefer not to use the package:

1. Install dependencies:
```bash
sudo pacman -S python python-evdev
```

2. Copy the script:
```bash
sudo cp middle-good-scrolling /usr/bin/
sudo chmod +x /usr/bin/middle-good-scrolling
```

3. Copy and enable the service:
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

### Service won't start
- Ensure you have the `python-evdev` package installed
- Check that `/dev/uinput` exists (you may need to load the `uinput` module: `sudo modprobe uinput`)
- Check permissions on `/dev/input/*` devices

## Requirements

- Python 3
- python-evdev
- Linux with evdev support
- Access to `/dev/input` and `/dev/uinput`
