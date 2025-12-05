# MagicTouch

Tap-to-click for Apple Magic Mouse. Free and open-source.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Tap to Click** — tap anywhere on Magic Mouse surface to click
- **Two Zones** — left zone for left click, right zone for right click
- **Double-tap** — automatically detected for text selection
- **Adjustable Zone Boundary** — configure where left ends and right begins
- **Menu Bar App** — lives in your menu bar, no dock icon
- **Launch at Login** — start automatically

## Requirements

- macOS 12.0+
- Apple Magic Mouse
- Accessibility permissions

## Installation

### Download Release (Recommended)

1. Download the latest DMG from [Releases](https://github.com/D3FVLT/MagicTouch/releases)
2. Open the DMG and drag MagicTouch to Applications
3. Launch MagicTouch and grant Accessibility permissions

The release is a Universal binary that works on both Apple Silicon and Intel Macs.

### Build from Source

```bash
brew install xcodegen
git clone https://github.com/D3FVLT/MagicTouch.git
cd MagicTouch
xcodegen generate
open MagicTouch.xcodeproj
```

Press `Cmd + R` to build and run.

## Usage

1. Grant Accessibility permissions on first launch
2. Click the hand icon in menu bar → Settings
3. Configure zone actions and boundary

## Default Configuration

| Zone | Action |
|------|--------|
| Left (0-50%) | Left Click |
| Right (50-100%) | Right Click |

Double-tap on left zone → Double-click (for text selection)

## How It Works

Uses Apple's private `MultitouchSupport.framework` to receive touch events. When a tap is detected, the configured action is executed via `CGEvent` API.

## Troubleshooting

**Taps not working?**
- Check Accessibility permissions in System Settings
- Make sure MagicTouch is enabled (checkmark in menu)
- Restart the app

**After rebuild, need to re-add to Accessibility?**
- Install to `/Applications` for stable path

## Limitations

- Uses private Apple framework (may break with macOS updates)
- Not available on Mac App Store

## Support

If you find this app useful, you can [buy me a coffee ☕](https://www.donationalerts.com/r/whitenobel)

## License

MIT

---

Made with ❤️ for Magic Mouse users who just want tap-to-click

