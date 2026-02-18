import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleSearch = Self("toggleSearch", default: .init(.space, modifiers: .option))
}

enum HotkeyManager {
    static func setup(action: @escaping () -> Void) {
        KeyboardShortcuts.onKeyUp(for: .toggleSearch) {
            action()
        }
    }
}
