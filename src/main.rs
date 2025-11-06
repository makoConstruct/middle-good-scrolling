use evdev::{Device, EventType, InputEventKind, Key, RelativeAxisType, uinput::VirtualDevice};
use std::path::Path;
use std::sync::{Arc, Mutex};
use std::thread;

/// Configuration for the scrolling behavior
#[derive(Debug, Clone)]
struct Config {
    drag_hysteresis: i32,
    scroll_speed: i32,
    invert_scroll: bool,
}

impl Default for Config {
    fn default() -> Self {
        Config {
            drag_hysteresis: 2,
            scroll_speed: 40,
            invert_scroll: true,
        }
    }
}

/// Shared state between threads
#[derive(Debug, Clone)]
struct SharedState {
    middle_pressed: bool,
    drag_distance_traveled: i32,
}

impl SharedState {
    fn new() -> Self {
        SharedState {
            middle_pressed: false,
            drag_distance_traveled: 0,
        }
    }
}

/// Load configuration from INI files
fn load_config() -> Config {
    let mut config = Config::default();
    let user_config = format!("{}/.config/middle-good-scrolling.conf",
                              std::env::var("HOME").unwrap_or_default());
    let config_paths = vec![
        "/etc/middle-good-scrolling.conf",
        &user_config,
    ];

    for path_str in config_paths {
        let path = Path::new(path_str);
        if path.exists() {
            match std::fs::read_to_string(path) {
                Ok(contents) => {
                    let mut in_settings = false;
                    for line in contents.lines() {
                        let line = line.trim();
                        if line.starts_with('[') && line.ends_with(']') {
                            in_settings = line == "[Settings]";
                        } else if in_settings && line.contains('=') {
                            let parts: Vec<&str> = line.splitn(2, '=').collect();
                            if parts.len() == 2 {
                                let key = parts[0].trim();
                                let value = parts[1].trim();
                                match key {
                                    "drag_hysteresis" => {
                                        if let Ok(parsed) = value.parse::<i32>() {
                                            config.drag_hysteresis = parsed;
                                        }
                                    }
                                    "scroll_speed" => {
                                        if let Ok(parsed) = value.parse::<i32>() {
                                            config.scroll_speed = parsed;
                                        }
                                    }
                                    "invert_scroll" => {
                                        config.invert_scroll = value.to_lowercase() == "true"
                                                               || value == "1"
                                                               || value.to_lowercase() == "yes";
                                    }
                                    _ => {}
                                }
                            }
                        }
                    }
                    println!("Loaded config from: {}", path_str);
                    break;
                }
                Err(e) => {
                    eprintln!("Warning: Error reading config from {}: {}", path_str, e);
                }
            }
        }
    }

    config
}

/// Calculate scroll speed based on distance traveled
#[inline(always)]
fn scroll_speed_for(distance_traveled: i32, config: &Config) -> i32 {
    config.scroll_speed * distance_traveled * if config.invert_scroll { -1 } else { 1 }
}

/// Find all mouse devices using udev
fn find_all_mice() -> Result<Vec<Device>, Box<dyn std::error::Error>> {
    let mut mice = Vec::new();
    let mut enumerator = udev::Enumerator::new()?;

    enumerator.match_subsystem("input")?;

    for device in enumerator.scan_devices()? {
        // Only look at event devices
        let devnode = match device.devnode() {
            Some(node) => node,
            None => continue,
        };

        let devnode_str = devnode.to_string_lossy();
        if !devnode_str.starts_with("/dev/input/event") {
            continue;
        }

        // Use udev properties to properly identify mice
        if device.property_value("ID_INPUT_MOUSE").map(|v| v == "1").unwrap_or(false) {
            // Skip touchpads, touchscreens, and tablets
            if device.property_value("ID_INPUT_TOUCHPAD").map(|v| v == "1").unwrap_or(false) {
                println!("Skipping: {} (touchpad)",
                         device.property_value("NAME").unwrap_or_default().to_string_lossy());
                continue;
            }
            if device.property_value("ID_INPUT_TOUCHSCREEN").map(|v| v == "1").unwrap_or(false) {
                println!("Skipping: {} (touchscreen)",
                         device.property_value("NAME").unwrap_or_default().to_string_lossy());
                continue;
            }
            if device.property_value("ID_INPUT_TABLET").map(|v| v == "1").unwrap_or(false) {
                println!("Skipping: {} (tablet)",
                         device.property_value("NAME").unwrap_or_default().to_string_lossy());
                continue;
            }

            match Device::open(&devnode) {
                Ok(input_device) => {
                    // Double-check that it has mouse buttons
                    if let Some(keys) = input_device.supported_keys() {
                        if keys.contains(Key::BTN_LEFT)
                           || keys.contains(Key::BTN_RIGHT)
                           || keys.contains(Key::BTN_MIDDLE) {
                            println!("Found mouse: {} ({})",
                                     input_device.name().unwrap_or("Unknown"),
                                     devnode_str);
                            mice.push(input_device);
                        }
                    }
                }
                Err(e) => {
                    eprintln!("Warning: Could not access {}: {}", devnode_str, e);
                }
            }
        }
    }

    Ok(mice)
}

/// Handle events from a single mouse device
fn handle_mouse(
    mut mouse: Device,
    virtual_device: Arc<Mutex<VirtualDevice>>,
    shared_state: Arc<Mutex<SharedState>>,
    config: Config,
) -> Result<(), Box<dyn std::error::Error>> {
    println!("Listening to: {} ({})",
             mouse.name().unwrap_or("Unknown"),
             mouse.physical_path().unwrap_or("Unknown"));

    // Grab the device to intercept all events
    mouse.grab()?;

    loop {
        for event in mouse.fetch_events()? {
            let kind = event.kind();

            match kind {
                InputEventKind::Key(Key::BTN_MIDDLE) => {
                    let mut state = shared_state.lock().unwrap();

                    if event.value() == 1 {
                        // Middle button pressed
                        state.middle_pressed = true;
                        // Don't forward the press event
                    } else if event.value() == 0 {
                        // Middle button released
                        state.middle_pressed = false;

                        // Only send click if drag distance < hysteresis
                        if state.drag_distance_traveled < config.drag_hysteresis {
                            let mut vdev = virtual_device.lock().unwrap();
                            vdev.emit(&[
                                evdev::InputEvent::new(EventType::KEY, Key::BTN_MIDDLE.code(), 1),
                                evdev::InputEvent::new(EventType::KEY, Key::BTN_MIDDLE.code(), 0),
                            ])?;
                        }
                        state.drag_distance_traveled = 0;
                    }
                }
                InputEventKind::RelAxis(axis) => {
                    let mut state = shared_state.lock().unwrap();

                    if state.middle_pressed {
                        state.drag_distance_traveled += event.value().abs();

                        // Convert mouse movement to scroll events
                        match axis {
                            RelativeAxisType::REL_X => {
                                let scroll_value = scroll_speed_for(event.value(), &config);
                                let mut vdev = virtual_device.lock().unwrap();
                                vdev.emit(&[
                                    evdev::InputEvent::new(
                                        EventType::RELATIVE,
                                        RelativeAxisType::REL_HWHEEL_HI_RES.0,
                                        scroll_value,
                                    ),
                                ])?;
                            }
                            RelativeAxisType::REL_Y => {
                                let scroll_value = -scroll_speed_for(event.value(), &config);
                                let mut vdev = virtual_device.lock().unwrap();
                                vdev.emit(&[
                                    evdev::InputEvent::new(
                                        EventType::RELATIVE,
                                        RelativeAxisType::REL_WHEEL_HI_RES.0,
                                        scroll_value,
                                    ),
                                ])?;
                            }
                            _ => {
                                // Forward other relative axis events
                                drop(state); // Release lock before forwarding
                                let mut vdev = virtual_device.lock().unwrap();
                                vdev.emit(&[event])?;
                            }
                        }
                    } else {
                        // Forward event when middle button not pressed
                        drop(state); // Release lock before forwarding
                        let mut vdev = virtual_device.lock().unwrap();
                        vdev.emit(&[event])?;
                    }
                }
                InputEventKind::Synchronization(_) => {
                    // Don't forward sync events - emit() handles this
                }
                _ => {
                    // Forward all other events unchanged
                    let mut vdev = virtual_device.lock().unwrap();
                    vdev.emit(&[event])?;
                }
            }
        }
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Load configuration
    let config = load_config();
    println!("Configuration: DRAG_HYSTERESIS={}, SCROLL_SPEED={}, INVERT_SCROLL={}",
             config.drag_hysteresis, config.scroll_speed, config.invert_scroll);

    // Find all mice
    let mice = find_all_mice()?;

    if mice.is_empty() {
        eprintln!("No mice found!");
        std::process::exit(1);
    }

    println!("Found {} mouse device(s)", mice.len());

    // Get capabilities from first mouse as template
    let first_mouse = &mice[0];
    let keys = first_mouse.supported_keys()
        .map(|k| k.iter().collect::<Vec<_>>())
        .unwrap_or_default();

    let mut rel_axes = first_mouse.supported_relative_axes()
        .map(|r| r.iter().collect::<Vec<_>>())
        .unwrap_or_default();

    // Ensure we have scroll wheel capabilities
    let scroll_axes = vec![
        RelativeAxisType::REL_WHEEL,
        RelativeAxisType::REL_HWHEEL,
        RelativeAxisType::REL_WHEEL_HI_RES,
        RelativeAxisType::REL_HWHEEL_HI_RES,
    ];

    for axis in scroll_axes {
        if !rel_axes.contains(&axis) {
            rel_axes.push(axis);
        }
    }

    // Create virtual input device
    let virtual_device = evdev::uinput::VirtualDeviceBuilder::new()?
        .name("middle-click-scroller")
        .with_keys(&evdev::AttributeSet::from_iter(keys.iter().copied()))?
        .with_relative_axes(&evdev::AttributeSet::from_iter(rel_axes.iter().copied()))?
        .build()?;

    println!("Created virtual input device");

    // Wrap virtual device in Arc<Mutex<>> for sharing between threads
    let virtual_device = Arc::new(Mutex::new(virtual_device));

    // Shared state for all mice
    let shared_state = Arc::new(Mutex::new(SharedState::new()));

    // Create threads for each mouse
    let mut threads = Vec::new();

    for mouse in mice {
        let state = Arc::clone(&shared_state);
        let virt_dev = Arc::clone(&virtual_device);
        let cfg = config.clone();

        let thread = thread::spawn(move || {
            if let Err(e) = handle_mouse(mouse, virt_dev, state, cfg) {
                eprintln!("Error handling mouse: {}", e);
            }
        });

        threads.push(thread);
    }

    println!("\n=== Ready! Hold middle-click and move mouse ===\n");

    // Wait for all threads
    for thread in threads {
        let _ = thread.join();
    }

    Ok(())
}
