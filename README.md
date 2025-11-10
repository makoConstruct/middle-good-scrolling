# defter scrolling

A better way of scrolling for the mouse. Makes it so that clicking a mouse button (by default, the middle mouse button) and dragging (anywhere on the page) is like clicking and dragging the scrollbar handle. This has a couple of advantages. Typically, the leverage of the scroll handle varies wildly depending on the length of the page, sometimes a scroll tab will be very small and so any mouse motion will translate to far too much view movement. Our belief is that the leverage of a scroll tab should be consistent, it shouldn't depend on the size of the page. Some few apps (eg, ripcord) adhere to this principle, implementing their own special scrollbar. If every app had made this choice, we wouldn't consider this package to be necessary. Alas.

This package also gives you horizontal scrolling (*and we do a special thing to prevent unintentional horizontal scroll movement from going through, code search "accumulator_vector" if you want the details*), which is a step up from most scroll wheels.

The activation button is configurable - you can use the middle button (default), back button, forward button, or any other mouse button. You can even specify a comma-separated list of buttons, and it will use the first one your mouse supports (perfect for mixed hardware setups).

If you need to use the activation button for its normal function (e.g., middle click), just do so without moving the mouse.

If any of your apps need to be able to distinguish the activation button's down event from up event, this package will break that, it delays the button down event until you (without moving/initiating a scroll) release the button (*if we didn't, an unwanted or unmatched button down event would fire every time the user wants to scroll. Not everyone knows this, but if you send a button down event without ever sending an up event it breaks all clicking.*), but apps that care about this distinction are rare, and often they provide other ways of doing whatever they used that for. There's a reason this is rarely a problem; windows long ago standardized another (generally worse) middle click drag behaviour, which we're replacing, so any app compatible with windows will be compatible with this. Some graphics apps use middle click drag to pan, but middle click scroll (what we're providing) is functionally equivalent to that! And many of these apps also bind that functionality to space-drag or some other keyboard input, which is just as good.

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

If people like it I think it should probably be part of KDE or something. - oh... Embarrassingly, only after making this did I realize KDE/libinput already basically has middle click scroll. Regardless, our implementation is way nicer, as things currently stand. Libinput has horrible defaults (very high initial friction, low scroll speed), gets stuck going either horizontal or vertical and can't do both at once (we have a more intelligent approach to this), if any of this is changeable, I have no idea where the configuration files are, and according to libinput, on wayland, there might not even be a configuration file for this stuff, it has to be exposed by the desktop environment, and KDE's graphics settings dialog certainly doesn't expose them currently, and if they're exposed in the settings, I again have no idea where they are.

## Configuration and Management

Configuration files are read in order of precedence:
1. `~/.config/defter-scrolling.conf` (per-user) (it wont be there at first, copy it using `cp /etc/defter-scrolling.conf ~/.config/defter-scrolling.conf`)
2. `/etc/defter-scrolling.conf` (system-wide)

Config example (this is the default):

```ini
[Settings]
# The mouse button(s) that activate scrolling
# Can be a single button or comma-separated list (tries each in order)
# Options: middle, back, forward, left, right
# Examples:
#   activation_button = middle          # Use middle button
#   activation_button = back, middle    # Use back button if available, otherwise middle
#   activation_button = forward, back   # Use forward if available, otherwise back
# Default: middle
activation_button = middle

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
