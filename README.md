# fast middle click scrolling

Hold middle mouse button and drag to scroll in any direction, fast. It's not like that middle click scrolling you may have encountered on windows, for instance, it's more like grabbing and dragging to scrolling is on mobile, but better, because you can (and should, and will by default) amplify the scroll speed so that it moves faster than a 1 to 1 drag gesture would. The default scroll speed is delightfully high. Note that this also gives you easy horizontal scrolling, can your mouse scroll wheel do that? Probably not. (*and don't worry, we do a special thing to prevent unintentional horizontal scroll movement from going through, see "accumulator_vector"*)

The behavior is a lot like clicking and dragging the scrollbar tab, but it's better than that in several ways. 1: you don't have to locate and scroll over to the mouse tab, which saves time because they're often hidden at first and then a narrow enough target that grabbing them is annoying to do. 2: Scroll tab leverage varies wildly, almost randomly. Sometimes a scroll tab will be very small and so any mouse motion will translate to far too much view movement, while at other times it'll be large and your scroll leverage will be disappointingly weak. Our position is that the size and leverage of a scroll tab shouldn't vary depending on the size of the view. Some few apps (ripcord) accept this position, but most don't. So most of the time you're gonna prefer *fast middle click scrolling* over the scroll tab.

## Installation

### Arch Linux

```bash
paru -U fast-middle-click-scrolling
```

### Other Platforms

Dunno. mako might do a debian/ubuntu version soon. Really though, we think this should be integrated into kde or something, and probably kde wouldn't want it to be a python script (not even we are fully comfortable with it being a python script)

## Configuration and Management

Configuration files are read in order of precedence:
1. `~/.config/fast-middle-click-scrolling.conf` (per-user)
2. `/etc/fast-middle-click-scrolling.conf` (system-wide)

You can then restart it using `systemctl restart --now middle-good-scrolling`

Config example (this is the default):

```ini
[Settings]
# Scroll speed multiplier
# Higher values = faster scrolling
scroll_speed = 30.0

# Invert scroll direction
# true = page scrolling (drag down to move the page contents down, which means moving the view up)
# false = view scrolling (drag down to move the view down, which means moving the page contents up)
invert_scroll = false

# the distance it has to travel along the horizontal axis before horizontal scrolling will go through. It's also required that the angle of the accumulator vector (length limit set below) exceeds 45° from the vertical.
horizontal_movement_threshold = 8.0

# How far (in pixels) to drag before considering it an intentional scroll and blocking the middle click events
# Lower values = more sensitive. It's acceptable for this to be 1. It shouldn't be set to 0.
drag_slop = 4.0

# the distance it has to travel along the vertical axis before vertical scrolling will go through. It's also required that the angle of the accumulator vector (length limit set below) exceeds 45° from the horizontal.
vertical_movement_threshold = 1.0

# if false, the software will do nothing and exit
enable = true

# the limit on the length of the accumulator vector. The lower it is, the faster the perceived angle will seem to change. If it's too low, input device jitter will cause incorrect scrolling. Needs to be higher than both horizontal_movement_threshold and vertical_movement_threshold.
accumulator_vector_limit = 10.0
```

After changing configuration, restart the service:
```bash
sudo systemctl restart middle-good-scrolling.service
```
