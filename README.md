# Please

A lightweight macOS Spotlight replacement — a menu-bar-only app that provides fuzzy application search and launch.

Type what you want, and Please will find and open it for you.

## Requirements

- macOS 13+
- Swift 6.0+ toolchain (included with Xcode 16+)

## Build

```bash
make          # Build the .app bundle
make run      # Build and launch
make clean    # Remove build artifacts
make lint     # Run SwiftLint (requires: brew install swiftlint)
make format   # Run SwiftFormat (requires: brew install swiftformat)
```

## Usage

1. **Launch** — Run `make run` or open `Please.app`. A magnifying glass icon appears in the menu bar.
2. **Open search** — Press **Option+Space** (configurable) or click the menu bar icon → Open...
3. **Search** — Type to fuzzy-filter installed applications. Arrow keys to navigate, Enter to launch, Escape to dismiss.
4. **Settings** — Click the menu bar icon → Settings... to configure:
   - Launch at login
   - Global hotkey
   - Max search results (3–20)
   - Font size (10–24pt)

## How It Works

- Scans `/Applications`, `/System/Applications`, and `~/Applications` (including one level of subdirectories like Utilities/)
- Fuzzy matching with scoring: consecutive characters, word boundaries, prefix matches, and name length all factor in
- Launches apps via `NSWorkspace`, or activates them if already running
- Uses `NSPanel` with `NSVisualEffectView` for a translucent, floating search window
- Global hotkey powered by [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)
