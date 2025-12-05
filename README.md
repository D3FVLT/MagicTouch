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

Requires [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project:

```bash
# Install XcodeGen (if not installed)
brew install xcodegen

# Clone and build
git clone https://github.com/D3FVLT/MagicTouch.git
cd MagicTouch
xcodegen generate
open MagicTouch.xcodeproj
```

Press `Cmd + R` to build and run.

> **Note:** After pulling updates from GitHub, run `xcodegen generate` again if new source files were added.

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

## Troubleshooting

### "MagicTouch can't be opened because it is from an unidentified developer"

- Right-click on the app → Open → Open
- Or: System Settings → Privacy & Security → scroll down → "Open Anyway"

### Taps not working?

1. Check Accessibility permissions: System Settings → Privacy & Security → Accessibility
2. Make sure MagicTouch is enabled (checkmark in menu bar)
3. Try **Reset Touch State** from the menu (⌘R) — fixes stuck touch detection
4. Restart the app

### Taps stopped working randomly?

This can happen after unusual touch gestures. Use **Reset Touch State** (⌘R) from the menu bar to fix it without restarting.

### After updating: "Open Anyway" and Accessibility permissions required again

**Why this happens:** MagicTouch is not code-signed (no Apple Developer account). macOS treats each new binary as a different app, requiring re-authorization.

**How to update properly:**

1. **Quit MagicTouch** (menu bar → Quit)
2. **Remove from Accessibility:**
   - System Settings → Privacy & Security → Accessibility
   - Select MagicTouch → click "−" button to remove
3. **Replace the app** with the new version in `/Applications`
4. **Launch the new version:**
   - Right-click → Open → Open (or use "Open Anyway" in Security settings)
5. **Re-grant Accessibility:**
   - The permission prompt should appear automatically
   - Or manually add in System Settings → Privacy & Security → Accessibility

> **Tip:** If the app doesn't appear in Accessibility list or permissions don't work, try restarting your Mac after step 2.

### After rebuild, need to re-add to Accessibility?

When building from source, the app path changes. To avoid this:

```bash
# Copy built app to Applications
cp -r ~/Library/Developer/Xcode/DerivedData/MagicTouch-*/Build/Products/Debug/MagicTouch.app /Applications/

# Then grant permissions to /Applications/MagicTouch.app
```

## Contributing

1. Fork the repo
2. Create a branch (`git checkout -b feature/cool-stuff`)
3. Make your changes
4. Test on both Apple Silicon and Intel if possible
5. Commit (`git commit -m "Add cool stuff"`)
6. Push (`git push origin feature/cool-stuff`)
7. Open a Pull Request

## Support

If you find this app useful, you can [buy me a coffee ☕](https://www.donationalerts.com/r/whitenobel)

## License

MIT

---

Made with ❤️ for Magic Mouse users who just want tap-to-click

