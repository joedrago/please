# Please — Developer Context

## Architecture

Menu-bar-only macOS app (LSUIElement=true). Hybrid AppKit + SwiftUI:
- **AppKit**: NSApplication bootstrap, NSPanel for search window, NSStatusItem for menu bar, NSTextField subclass for key interception
- **SwiftUI**: Search view content, settings view, hosted inside AppKit containers via NSHostingView/NSHostingController
- **SPM + Makefile**: `swift build` compiles; Makefile assembles `.app` bundle

## Build Commands

```bash
make          # Build .app bundle
make run      # Build and launch
make clean    # Remove build artifacts
make lint     # SwiftLint
make format   # SwiftFormat
make icon     # Regenerate AppIcon.icns from scripts
make sign     # Code-sign the .app (requires DEVELOPER_ID)
make notarize # Sign + notarize the .app (requires NOTARY_PROFILE)
make dmg      # Full release: sign, notarize, build DMG
```

## Key Files

- `main.swift` — NSApplication.shared bootstrap (not @main)
- `AppDelegate.swift` — Central coordinator, owns StatusBar/SearchPanel/Settings controllers
- `SearchPanelController.swift` — Creates/shows/hides the NSPanel with embedded SwiftUI
- `SearchView.swift` + `SearchViewModel` — SwiftUI root view with search logic
- `SearchField.swift` — NSViewRepresentable wrapping custom NSTextField (intercepts arrows/Enter/Escape)
- `FuzzyMatcher.swift` — Subsequence matching with scoring
- `AppFinder.swift` — Scans application directories, returns [AppInfo]
- `HotkeyManager.swift` — KeyboardShortcuts integration (Option+Space default)
- `Preferences.swift` — UserDefaults keys (maxResults, fontSize)
- `SettingsView.swift` — SwiftUI Form with launch-at-login, hotkey recorder, appearance
- `scripts/generate-icon.swift` — Standalone Swift script that draws the app icon (1024x1024 PNG)
- `scripts/generate-icns.sh` — Converts PNG to `.icns` via `sips` + `iconutil`
- `scripts/dmgbuildSettings.py` — Settings for `dmgbuild` (DMG installer layout)

## Conventions

- Swift 5 language mode (via `swiftLanguageMode(.v5)` in Package.swift) to avoid strict concurrency
- Single external dependency: KeyboardShortcuts
- Re-scans apps on every search panel open (no caching)
- SMAppService for launch-at-login (macOS 13+)

## Release / Code Signing

- `make dmg DEVELOPER_ID="Developer ID Application: Your Name (TEAMID)"` — full release pipeline
- Notarization requires a stored keychain profile: `xcrun notarytool store-credentials "please-notary"`
- `dmgbuild` (Python) must be installed: `pip install dmgbuild`

## Adding Features

- New search sources: add to `AppFinder.findApplications()` or create a parallel finder
- New settings: add key to `Preferences`, add control to `SettingsView`. Increase the `.frame(height:)` in `SettingsView` to fit the new controls.
- New hotkeys: extend `KeyboardShortcuts.Name` in `HotkeyManager.swift`
