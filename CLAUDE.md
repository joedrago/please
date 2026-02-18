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

## Conventions

- Swift 5 language mode (via `swiftLanguageMode(.v5)` in Package.swift) to avoid strict concurrency
- Single external dependency: KeyboardShortcuts
- Re-scans apps on every search panel open (no caching)
- SMAppService for launch-at-login (macOS 13+)

## Adding Features

- New search sources: add to `AppFinder.findApplications()` or create a parallel finder
- New settings: add key to `Preferences`, add control to `SettingsView`. Increase the `.frame(height:)` in `SettingsView` to fit the new controls.
- New hotkeys: extend `KeyboardShortcuts.Name` in `HotkeyManager.swift`
