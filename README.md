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
make install  # Build and install to /Applications
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

## Releasing a Signed DMG

`make dmg` builds, signs, notarizes, and packages the app into an installer DMG. This requires a one-time setup.

### 1. Set your Developer ID

Find your signing identity (requires a "Developer ID Application" certificate from Apple):

```bash
security find-identity -v -p codesigning | grep "Developer ID Application"
```

This prints something like:

```
1) ABCDEF1234... "Developer ID Application: Your Name (XXXXXXXXXX)"
```

Save the quoted string to `~/.appledevid`:

```bash
security find-identity -v -p codesigning \
  | grep "Developer ID Application" \
  | head -1 \
  | sed 's/.*"\(.*\)".*/\1/' > ~/.appledevid
```

Verify it looks right:

```bash
cat ~/.appledevid
# Should show: Developer ID Application: Your Name (XXXXXXXXXX)
```

### 2. Store notarization credentials

Apple notarization requires an app-specific password. Generate one at [appleid.apple.com](https://appleid.apple.com/) under Sign-In and Security → App-Specific Passwords.

Then store the credentials in your keychain:

```bash
xcrun notarytool store-credentials "please-notary" \
    --apple-id "your@email.com" \
    --team-id "XXXXXXXXXX" \
    --password "xxxx-xxxx-xxxx-xxxx"
```

The team ID is the 10-character string in parentheses from your Developer ID (step 1). The `please-notary` profile name matches what the Makefile expects.

### 3. Build the DMG

```bash
make dmg
```

This runs the full pipeline: `build` → `bundle` → `sign` → `notarize` → `dmg`. The venv and `dmgbuild` are installed automatically on first run. The output is `Please-<version>.dmg`.

## How It Works

- Scans `/Applications`, `/System/Applications`, and `~/Applications` (including one level of subdirectories like Utilities/)
- Fuzzy matching with scoring: consecutive characters, word boundaries, prefix matches, and name length all factor in
- Launches apps via `NSWorkspace`, or activates them if already running
- Uses `NSPanel` with `NSVisualEffectView` for a translucent, floating search window
- Global hotkey powered by [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)
