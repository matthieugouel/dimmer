# Dimmer

A lightweight macOS menu bar app that dims your screen beyond the system minimum brightness.

Dimmer works by adjusting your display's gamma transfer function, which means it operates at the display driver level rather than using overlay windows. This makes it work seamlessly everywhere — including full-screen apps, multiple Spaces, and multi-monitor setups — with no flickering or visual artifacts.

## Features

- Menu bar app with no dock icon
- Preset dim levels: 10%, 20%, 50%, 75%
- Works in full-screen mode without blinking

## Build & Run

Requires Swift 5.9+ and macOS 13+.

```bash
swift build
.build/debug/Dimmer
```

To build a `.app` bundle you can drag to `/Applications`:

```bash
make bundle
cp -r Dimmer.app /Applications/Dimmer.app
```

## How It Works

Dimmer uses the Core Graphics `CGSetDisplayTransferByFormula` API to modify the display's color transfer function. By reducing the maximum output value for each color channel (red, green, blue), the effective brightness of the display is lowered. Calling `CGDisplayRestoreColorSyncSettings` restores the original display settings when dimming is cleared.

This approach operates below the window system, so it is unaffected by Spaces transitions, full-screen animations, or window layering.

## Acknowledgements

Inspired by [SPF](https://github.com/tannerc/spf), which uses transparent overlay windows to achieve a similar effect. Dimmer takes a different approach to avoid issues with full-screen mode and multiple Spaces.

