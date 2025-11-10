# middle good scrolling

A better way of scrolling for the mouse. Makes it so that clicking the middle mouse button down and dragging (anywhere on the page) is like clicking and dragging the scrollbar handle. This has two advantages. You're no longer required to find and click the scrollbar, additionally, typically, the leverage of the scroll handle varies wildly depending on the length of the page, sometimes a scroll tab will be very small and so any mouse motion will translate to far too much view movement. Our belief is that the size and leverage of a scroll tab should be consistent, it shouldn't depend on the size of the page. Some apps (eg, ripcord) have acted on this belief and customized their scrollbar behavior appropriately, and if every app had made the right choice there we wouldn't consider this package to be necessary. Alas.

This package also gives you horizontal scrolling (*and we do a special thing to prevent unintentional horizontal scroll movement from going through, code search "accumulator_vector" if you want the details*), which is a step up from most scroll wheels.

If you need to middle click, just do so without moving the mouse.

If any of your apps need to be able to distinguish the middleclick down event from middleclick up event, this package will break that, it delays middleclick down event until you (without moving/initiating a scroll) release the middle click button (*if we didn't, an unwanted or unmatched middleclick down event would fire every time the user wants to scroll. Not everyone knows this, but if you send a middleclick down event without ever sending an up event it breaks all clicking.*), but apps that care about this distinction are vanishingly rare, and there's a reason it's rare; windows long ago standardized another (generally less useful) middle click drag behaviour, which we're replacing, so such apps would've also been incompatible with that, so I'm not sure there are any such apps. I vaguely remember using middle click drag to pan in some graphics apps, but middle click scroll (what we're providing) is functionally equivalent to that! And at least some of these apps also bind that functionality to space-drag.

## Install

### Arch Linux

```bash
# install from the aur
paru -U middle-good-scrolling
# enable (activate) the service (this will persist through system restarts)
systemctl enable --now middle-good-scrolling
```

### Other Platforms

Dunno. Might do a debian/ubuntu version soon. If people like it I think it should probably be part of KDE or something, which might warrant a port to a language that's not as ridiculous.

## Configuration and Management

Configuration files are read in order of precedence:
1. `~/.config/middle-good-scrolling.conf` (per-user) (it wont be there at first, copy it using `cp /etc/middle-good-scrolling.conf ~/.config/middle-good-scrolling.conf`)
2. `/etc/middle-good-scrolling.conf` (system-wide)

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
sudo systemctl restart middle-good-scrolling
```
