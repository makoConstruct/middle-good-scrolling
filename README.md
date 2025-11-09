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
scroll_speed = 30

# Invert scroll direction
# true = material scrolling (drag down to move the page contents down, which means scrolling up)
# false = vulgar scrolling (drag down to scroll down, which means moving the page contents up)
invert_scroll = true

# the distance it has to travel along the horizontal axis before horizontal scrolling will go through. It's also required that horizontal distance exceeds a certain angle, see below
horizontal_movement_threshold = 8

# How far (in pixels) to drag before considering it an intentional scroll and blocking the middle click events
# Lower values = more sensitive. It's acceptable for this to be 1. It shouldn't be set to 0.
drag_slop = 4

# the distance it has to travel along the vertical axis before vertical scrolling will go through.
vertical_movement_threshold = 1

# if false, the software will do nothing and exit
enable = true

# the limit on the length of the accumulator vector. The lower it is, the faster the perceived angle will seem to change. If it's too low, input device jitter will cause incorrect scrolling. Needs to be higher than both horizontal_movement_threshold and vertical_movement_threshold.
accumulator_vector_limit = 10
```

After changing configuration, restart the service:
```bash
sudo systemctl restart middle-good-scrolling.service
```
