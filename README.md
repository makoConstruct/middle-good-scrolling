# middle-good-scrolling

A mouse event interceptor that enables scrolling by holding the middle mouse button and dragging, similar to functionality found in some browsers and applications.

## Features

- Hold middle mouse button and drag to scroll in any direction
- Vertical and horizontal scrolling support
- Configurable scroll speed and sensitivity
- Automatically detects and works with multiple mice
- Excludes touchpads and touchscreens
- Runs as a system service
- Preserves normal middle-click functionality (when not dragging)

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

### Configuration options

Edit `/etc/middle-good-scrolling.conf`:

```ini
[Settings]
# How far (in pixels) to drag before considering it an intentional scroll
# Lower values = more sensitive, higher values = less accidental scrolling
drag_hysteresis = 4

# Scroll speed multiplier
# Higher values = faster scrolling
scroll_speed = 40

# Invert scroll direction
# true = natural scrolling (drag down to scroll down)
# false = reverse scrolling (drag down to scroll up)
invert_scroll = true
```

After changing configuration, restart the service:
```bash
sudo systemctl restart middle-good-scrolling.service
```

## Usage

Once the service is running:
1. Hold down the middle mouse button
2. Move your mouse in any direction
3. Release the middle mouse button

If you don't drag far enough (less than `drag_hysteresis`), a normal middle-click event is sent instead.

## Troubleshooting

### Check service status
```bash
sudo systemctl status middle-good-scrolling.service
```

### View logs
```bash
sudo journalctl -u middle-good-scrolling.service -f
```

### Test manually
Stop the service and run manually to see debug output:
```bash
sudo systemctl stop middle-good-scrolling.service
sudo /usr/bin/middle-good-scrolling
```

### Service won't start
- Ensure you have the `python-evdev` package installed
- Check that `/dev/uinput` exists (you may need to load the `uinput` module: `sudo modprobe uinput`)
- Check permissions on `/dev/input/*` devices

## How it works

The program:
1. Scans for all mouse devices (excluding touchpads)
2. Grabs exclusive control of those devices using `evdev`
3. Creates a virtual input device to forward events
4. Intercepts middle mouse button events:
   - When pressed, starts tracking movement
   - Converts movement to scroll wheel events
   - On release, sends a middle-click if no significant dragging occurred
5. Forwards all other mouse events unchanged

## License

MIT

## Contributing

Contributions welcome! Please open an issue or pull request.

## Requirements

- Python 3
- python-evdev
- Linux with evdev support
- Access to `/dev/input` and `/dev/uinput`
