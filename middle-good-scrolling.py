#!/usr/bin/env python3
import evdev
from evdev import UInput, ecodes as e
import sys
import threading
import os
import configparser

# Default configuration
DEFAULT_CONFIG = {
    'DRAG_HYSTERESIS': 2,
    'SCROLL_SPEED': 40,
    'INVERT_SCROLL': True
}

def load_config():
    """Load configuration from file or use defaults"""
    config = DEFAULT_CONFIG.copy()
    config_paths = [
        '/etc/middle-good-scrolling.conf',
        os.path.expanduser('~/.config/middle-good-scrolling.conf')
    ]

    parser = configparser.ConfigParser()
    for path in config_paths:
        if os.path.exists(path):
            try:
                parser.read(path)
                if 'Settings' in parser:
                    if 'drag_hysteresis' in parser['Settings']:
                        config['DRAG_HYSTERESIS'] = parser.getint('Settings', 'drag_hysteresis')
                    if 'scroll_speed' in parser['Settings']:
                        config['SCROLL_SPEED'] = parser.getint('Settings', 'scroll_speed')
                    if 'invert_scroll' in parser['Settings']:
                        config['INVERT_SCROLL'] = parser.getboolean('Settings', 'invert_scroll')
                print(f"Loaded config from: {path}")
                break
            except Exception as ex:
                print(f"Warning: Error reading config from {path}: {ex}")

    return config

def scroll_speed_for(distance_traveled, config):
    return config['SCROLL_SPEED'] * distance_traveled * (-1 if config['INVERT_SCROLL'] else 1)

def find_all_mice():
    devices = [evdev.InputDevice(path) for path in evdev.list_devices()]
    mice = []
    for device in devices:
        name_lower = device.name.lower()
        # hacky way of detecting touchpads and touchscreens
        # we filter them out because for some reason (??) they stop working when we grab them even though (I'm pretty sure) we forward all of their events
        if any(skip in name_lower for skip in ['touchpad', 'trackpad', 'synaptics', 'elan', 'touchscreen']):
            print(f"Skipping: {device.name} (touchpad/touchscreen)")
            continue
        caps = device.capabilities().get(e.EV_KEY, [])
        if any(btn in caps for btn in [e.BTN_LEFT, e.BTN_RIGHT, e.BTN_MIDDLE]):
            mice.append(device)
            print(f"Found mouse: {device.name} ({device.path})")
    return mice

def handle_mouse(mouse, ui, shared_state, config):
    print(f"Listening to: {mouse.name} ({mouse.path})")

    # Grab the device to intercept all events
    mouse.grab()

    try:
        for event in mouse.read_loop():
            if event.type == e.EV_KEY and event.code == e.BTN_MIDDLE:
                if event.value == 1:
                    shared_state['middle_pressed'] = True
                    # Don't forward the press event, only send a middle click when we know we're not scrolling (on release)
                elif event.value == 0:
                    shared_state['middle_pressed'] = False
                    if shared_state['drag_distance_traveled'] < config['DRAG_HYSTERESIS']:
                        ui.write(e.EV_KEY, e.BTN_MIDDLE, 1)
                        ui.write(e.EV_KEY, e.BTN_MIDDLE, 0)
                    shared_state['drag_distance_traveled'] = 0
            elif event.type == e.EV_REL and shared_state['middle_pressed']:
                shared_state['drag_distance_traveled'] += abs(event.value)
                # Convert mouse movement to scroll events
                # I don't know why but it seems like we have to invert the vertical scroll direction but not the horizontal. Maybe mouse and X11 coordinates are vertically flipped?
                if event.code == e.REL_X:
                    ui.write(e.EV_REL, e.REL_HWHEEL_HI_RES, scroll_speed_for(event.value, config))
                    ui.syn()
                elif event.code == e.REL_Y:
                    ui.write(e.EV_REL, e.REL_WHEEL_HI_RES, -scroll_speed_for(event.value, config))
                    ui.syn()
            else:
                # Forward all other events unchanged
                ui.write(event.type, event.code, event.value)
                ui.syn()

    except Exception as ex:
        print(f"Error with {mouse.name}: {ex}")
        import traceback
        traceback.print_exc()

def main():
    # Load configuration
    config = load_config()
    print(f"Configuration: DRAG_HYSTERESIS={config['DRAG_HYSTERESIS']}, SCROLL_SPEED={config['SCROLL_SPEED']}, INVERT_SCROLL={config['INVERT_SCROLL']}")

    mice = find_all_mice()

    if not mice:
        print("No mice found!")
        sys.exit(1)

    print(f"Found {len(mice)} mouse device(s)")

    # Create UInput with button and scroll wheel capabilities
    # We need to forward all mouse events, so we need to get the capabilities from a mouse
    if mice:
        # Use the first mouse's capabilities as a template
        mouse_caps = mice[0].capabilities()
        cap = {}
        if e.EV_KEY in mouse_caps:
            cap[e.EV_KEY] = mouse_caps[e.EV_KEY]
        if e.EV_REL in mouse_caps:
            rel_caps = mouse_caps[e.EV_REL].copy()
            # Ensure we have scroll wheel capabilities
            scroll_caps = [e.REL_WHEEL, e.REL_HWHEEL, e.REL_WHEEL_HI_RES]
            for sc in scroll_caps:
                if sc not in rel_caps:
                    rel_caps.append(sc)
            cap[e.EV_REL] = rel_caps
    else:
        # Fallback if no mice found (shouldn't happen)
        cap = {
            e.EV_KEY: [e.BTN_LEFT, e.BTN_RIGHT, e.BTN_MIDDLE],
            e.EV_REL: [e.REL_X, e.REL_Y, e.REL_WHEEL, e.REL_HWHEEL, e.REL_WHEEL_HI_RES],
        }

    ui = UInput(cap, name='middle-click-scroller')
    print(f"Created virtual input device: {ui.device.name}")

    shared_state = {
        'middle_pressed': False,
        # tracks whether it dragged far enough to state that the drag action was intentional
        'drag_distance_traveled': 0,
    }

    threads = []
    for mouse in mice:
        thread = threading.Thread(target=handle_mouse, args=(mouse, ui, shared_state, config))
        thread.daemon = True
        thread.start()
        threads.append(thread)

    print("\n=== Ready! Hold middle-click and move mouse ===\n")

    try:
        for thread in threads:
            thread.join()
    except KeyboardInterrupt:
        print("\nStopping...")
    finally:
        ui.close()

if __name__ == "__main__":
    main()
