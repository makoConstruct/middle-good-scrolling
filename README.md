# defter scrolling

A better way of scrolling, for mice.

Makes it so that clicking your chosen mouse button and dragging (anywhere on the page) is like clicking and dragging the scrollbar handle (but better in various ways, see below).

Many desktop environments offer functionality like this with middle click, but we allow (and recommend, and, by default, will be, if possible) binding it to a more comfortable button like the forward button, if you have one. Our implementation is different than libinput's/kde's in a way that feels smoother and less rigid. We're generally easier to configure than libinput stuff (*last we checked (late 2025) configuring libinput's middle click scroll behavior is currently difficult or impossible on wayland-kde*)

We also give you horizontal/biaxial scrolling, when you want it.

Generally, defter scrolling wont interfere with other uses of the assigned button, since we only absorb the activation button click if you begin a drag. This will interfere with apps that use drags with that button, but such cases are very rare, and even in these cases (*eg, some graphics apps use middle-click scroll to pan the page*) apps generally provide alternative ways of doing those things (*eg, letting you pan by pressing space instead, which I've always thought was just as good.*).

If you're not convinced, see [Design commentary](#design-commentary). Or just give it a try and see how it feels!

## Install

### Arch Linux

```bash
# install from the aur
paru -S defter-scrolling
# enable (activate) the service (this will persist through system restarts)
systemctl enable --now defter-scrolling
```

### Debian

We'd like to have a deb package. For now debian users can use the install script below.

There's [a branch](https://github.com/makoConstruct/middle-good-scrolling/pull/13) where a debian package config has been generated. Debian's packaging format seems pretty gnarly so mako can't just eyeball it, a debian user will need to test this before we can merge it.

### General Linux Installer

Get dependencies if needed:
Ubuntu/Debian `sudo apt install python3 python3-evdev python3-pyudev`
Fedora `sudo dnf install python3 python3-evdev python3-pyudev`
Or using pip `pip install --user evdev pyudev`

Install:
  ```bash
  git clone https://github.com/makoConstruct/middle-good-scrolling.git
  cd middle-good-scrolling
  ./install.sh
  ```

The install script will automatically enable and start the service.

**To uninstall:**
```bash
./uninstall.sh
```

### Direct integration into desktop environments

It would be nice to get these refinements on click-scrolling adopted with libinput, if someone could help with that, it would be appreciated. We do plan to reach out to KDE.

## Configuration and Management

Configuration files are read in order of precedence:
1. `~/.config/defter-scrolling.conf` (per-user) (it wont be there at first, copy it using `cp /etc/defter-scrolling.conf ~/.config/defter-scrolling.conf`)
2. `/etc/defter-scrolling.conf` (system-wide)

Config example (this is the default):

```ini
[Settings]
# ideally most of this would be measured in mms rather than pixels, I haven't looked into it, generally computers don't give you accurate mms per pixel, even android phones don't give hte os accurate info about that. Device manufacturers (and desktop environments) are in a state of sin and don't even try to provide it, or they tweak it to an arbitrary value that most suits the taste of whichever two or three non-designers in the company even know that the screen makes a claim to the os about its size. and it's never the true size. So instead we just measure in the unit of the amount of pixels that the mouse has moved.

# The mouse buttons that can activate scrolling. Only the first one that is present on the mouse will be used, the rest are fallbacks.
# We recommend setting this to 'forward' if you have it (It's usually more comfortable to click, and it's used less often, and apps never use it for drag actions), but not everyone has it, so it defaults to middle after that, and if you don't have middle, it'll default to right click.
# Options: middle, back_proper, back (which is officially called BTN_SIDE), forward_proper, forward (which is officially called BTN_EXTRA), left, right, You can also use any of the standard linux/input.h button codes.
activation_buttons = BTN_FORWARD, forward, back, middle, right

# The amount of scroll pixels sent through per mouse-pixel of movement
# Higher values = faster scrolling
scroll_speed = 22.0

# Invert scroll direction
# true = page scrolling (drag down to move the page contents down, which means moving the view up)
# false = view scrolling (drag down to move the view down, which means moving the page contents up)
invert_scroll = false

# How far it must be dragged before it'll consider it an intentional scroll and block the activation button click events
# Lower values = more sensitive. It's acceptable for this to be 1. It shouldn't be set to 0.
drag_slop = 4.0

# the threshold within which it can switch axis without making a commitment
# also used to determine how long the accumulator vector needs to be before an axis break is allowed. Perhaps there should be a separate variable for that, but it's hard to have an opinion about it.
axis_decision_threshold = 13.0

# if false, the software will do nothing and exit
enable = true

# the limit on the length of the accumulator vector. The lower it is, the faster the perceived angle will seem to change. If it's too low, input device jitter will cause incorrect scrolling. Needs to be higher than both horizontal_movement_threshold and vertical_movement_threshold.
accumulator_vector_limit = 16.0

# temporarily enabled to see if it just feels better (I have been experiencing unintentional biaxial scrolling and right now it just feels doomed)
# effectively disabled by default, I expect no one will ever enable it, maybe we should remove it.
# when biaxial scrolling is started, axis_break_max_jump is how far should we be able to jump back towards the actual position of the mouse. If you set this to inf, it can in theory make the axis breaking more obedient to the user's mouse movements, going right where they placed the mouse. If you set it to a small value, it creates a little sort of pop motion when biaxial scrolling activates, which makes it very clear to the user how biaxial scrolling works. But I'm not sure they really need this tutorialized...
# thinking about this is making me think that maybe we should switch to a less strict axis breaking system
axis_break_max_jump = 6.0
```

After changing configuration, restart the service:
```bash
sudo systemctl restart defter-scrolling
```

## Design commentary

### Preventing unintentional off-axis movement

We do this in a non-obvious, defter way than more common approaches like strict axis locking and hysteresis.

We keep a vector that's basically the sum of the most recent mouse movements, but length-limited. This is like a smoothed out running average over recent movement. When this accumulator is over a certain length, we take its angle. We activate the axis it's closest to, leaving the other inactive. The other axis can be activated later if the user points the accumulator towards it, and biaxial scrolling will begin.

### In relation to other scrolling modalities

The standard behaviors of scrollbars are flawed. The leverage by which movement of the scrollbar handle translates into movement of the page varies a lot depending on the length of the page, sometimes a scroll tab will be a little sliver and so any mouse motion will produce far too much page movement, it will be uncontrollable. When you need to reach for the handle, it will be in a random position, and it will be too narrow. There have been apps that recognized these flaws and hacked up their scrollbar and made it sane, but they're rare. The only one that comes to mind for me is [ripcord](https://cancel.fm/ripcord/), an old discord client (*I would recommend it except for the fact that it seems like discord delete you if you use it, even though third party clients were never mentioned in the ToS and afaik still aren't*) built in Qt. The scrollbar was all handle, and dragging it would always move the page at the rate you'd expect. If all scrollbars were like this, we wouldn't really need *defter scrolling*. Alas. But it's okay, defter scrolling is better than any scrollbar, since it spares you from having to move the mouse to the scrollbar whenever you want to scroll, it works anywhere on the page.

Mouse wheels? Well, clicky mouse wheels are not great for scrolling. They either move only in small increments (too slow for searching or skimreading), or in large increments (too little control, too jerky). There are analog mouse wheels, which are good, and if all mouse wheels were like that, again, I might not have felt a need to make defter scrolling. Alas. But again, it's not so bad, defter scrolling is even better than analog mouse wheels, as it also supports horizontal scrolling, and it's a bit more comfortable and controllable to use ordinary mouse movement to scroll than it is to flick a wheel with your finger.

Touchpads, or mice with touch surfaces? No notes. They're great. I think Mac users wont have much of an apetite for defter scrolling. I still think defter scrolling is a *little bit* better than those devices, but it is better by so little that it's not worth dwelling on.

### On dragging and dropping

Some analog mouse wheels also allow low friction free-wheeling, which is very nice. And those are the only scrolling modality aside from defter scrolling that has this unique quality of supporting the dragging and dropping things over very long distances.

As far as I'm aware, mac touch surfaces don't support dragging and dropping items over long distances.

Though I think a user should never really *need* to drag and drop things over long distances. Cutting and pasting (*or stowing and popping, or whatever, some other way of moving items*) would always be better, if supported, and where it's not supported, that's an obvious enough shortcoming that any project should be open to fixing it.

It's just kinda nice to have. Sometimes the user will initiate a drag without knowing where they're going to place the item down, they may not know before moving the item whether they should make it a drag or a cut&paste.

It's worth noting... I think mac trackpad hardware *could* support this. How I'd do it is, if the user clicks down on an item, then introduces another finger and moves it while keeping the original finger still, the movement of the second finger would move the item. This could conceivably interfere with some two finger scroll gestures and so apple has probably forbidden it. Mac users, please tell me whether this is the case.