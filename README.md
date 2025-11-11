# defter scrolling

A better way of scrolling for your mouse: Makes it so that clicking your chosen mouse button and dragging (anywhere on the page) is like clicking and dragging the scrollbar handle (but better in various ways, see below). Many desktop environments offer functionality like this with middle click, but we allow (and recommend, and, by default, will be, if possible) binding it to a more comfortable button like the forward button, if you have one. Our implementation is also just more carefully tuned (feels less sticky, or rigid) and we're generally easier to configure than libinput stuff (*last we checked (late 2025) configuring libinput's middle click scroll behavior is currently difficult or impossible on wayland-kde*)

We also give you horizontal scrolling (*and we have a special technique to prevent unintentional horizontal scroll movement from going through without preventing you from engaging in intentional biaxial movement, code search "accumulator_vector" if you want the details*).

### conventional ways of scrolling that *defter scrolling* is definitely better than:

- Grabbing and dragging the scroll handle: Usually, the handle movement to page movement ratio of the average scrollbar varies wildly depending on the length of the page, sometimes a scroll tab will be a little sliver and so any mouse motion will produce far too much page movement, leading to unpredictable and uncontrollable scrolling. It's not like that with this.

- Mouse wheel: Most are not very good, only scroll in small increments. If you have a rare good mouse wheel, see below.

### Other ways of scrolling that *defter scrolling* isn't necessarily better than:

- Trackpad two-finger scroll: If you have one of these you don't need defter scrolling imo.

- *Analog* mouse wheels: Unsure, I'd say these are only slightly worse than defter scrolling. There are some analog mouse wheels that can spin freely with low friction, those are okay. They don't support horizontal scrolling, and flicking the wheel with your finger isn't really as ergonomic or controllable as just moving the mouse normally, so I still think they're worse on net.

Generally, defter scrolling wont interfere with other uses of the assigned button, since we only absorb the activation button click if you begin a drag. This will interfere with apps that use drags with that button, but such cases are very rare, and even in these cases (*eg, some graphics apps use middle-click scroll to pan the page*) apps generally provide alternative ways of doing those things (*letting you pan by pressing space instead, which I've always thought was really nice*).

## Install

### Arch Linux

```bash
# install from the aur
paru -U defter-scrolling
# enable (activate) the service (this will persist through system restarts)
systemctl enable --now defter-scrolling
```

### Other Platforms

Dunno. Might do a debian/ubuntu version soon.

I'd like to get this implementation into libinput, if you could help with that it would be greatly appreciated.

## Configuration and Management

Configuration files are read in order of precedence:
1. `~/.config/defter-scrolling.conf` (per-user) (it wont be there at first, copy it using `cp /etc/defter-scrolling.conf ~/.config/defter-scrolling.conf`)
2. `/etc/defter-scrolling.conf` (system-wide)

Config example (this is the default):

```ini
[Settings]
# The mouse buttons that can activate scrolling. Only the first one that is present on the mouse will be used, the rest are fallbacks.
# We recommend setting this to 'forward' if you have it (this is the default) (forward is usually more comfortable to click, and it's used less often, and apps never use it for drag actions), but not everyone has it, so the default setting will fall back to 'back' after that, and if you don't have that, 'middle', and if you don't have middle, it'll default to 'right'.
# Options: middle, back_proper, back (which is officially called BTN_SIDE), forward_proper, forward (which is officially called BTN_EXTRA), left, right, You can also use any of the standard linux/input.h button codes.
activation_buttons = BTN_FORWARD, forward, back, middle, right

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
sudo systemctl restart defter-scrolling
```
