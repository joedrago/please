import Foundation
import KeyboardShortcuts

enum Preferences {
    private static let defaults = UserDefaults.standard

    enum Key {
        static let maxResults = "maxResults"
        static let fontSize = "fontSize"
        static let calculatorEnabled = "calculatorEnabled"
        static let fuzzySearch = "fuzzySearch"
        static let lowPriorityApps = "lowPriorityApps"
        static let highPriorityApps = "highPriorityApps"
        static let appAliases = "appAliases"
        static let launchAtLogin = "launchAtLogin"
    }

    static func registerDefaults() {
        defaults.register(defaults: [
            Key.maxResults: 5,
            Key.fontSize: 16,
            Key.calculatorEnabled: false,
            Key.fuzzySearch: true,
        ])
    }

    static var maxResults: Int {
        get { defaults.integer(forKey: Key.maxResults) }
        set { defaults.set(newValue, forKey: Key.maxResults) }
    }

    static var fontSize: CGFloat {
        get { CGFloat(defaults.double(forKey: Key.fontSize)) }
        set { defaults.set(Double(newValue), forKey: Key.fontSize) }
    }

    static var calculatorEnabled: Bool {
        get { defaults.bool(forKey: Key.calculatorEnabled) }
        set { defaults.set(newValue, forKey: Key.calculatorEnabled) }
    }

    static var fuzzySearch: Bool {
        get { defaults.bool(forKey: Key.fuzzySearch) }
        set { defaults.set(newValue, forKey: Key.fuzzySearch) }
    }

    static var lowPriorityApps: Set<String> {
        get { Set(defaults.stringArray(forKey: Key.lowPriorityApps) ?? []) }
        set { defaults.set(Array(newValue), forKey: Key.lowPriorityApps) }
    }

    static func toggleLowPriority(_ appID: String) {
        var apps = lowPriorityApps
        if apps.contains(appID) {
            apps.remove(appID)
        } else {
            var high = highPriorityApps
            high.remove(appID)
            highPriorityApps = high
            apps.insert(appID)
        }
        lowPriorityApps = apps
    }

    static var highPriorityApps: Set<String> {
        get { Set(defaults.stringArray(forKey: Key.highPriorityApps) ?? []) }
        set { defaults.set(Array(newValue), forKey: Key.highPriorityApps) }
    }

    static var appAliases: [String: String] {
        get { defaults.dictionary(forKey: Key.appAliases) as? [String: String] ?? [:] }
        set { defaults.set(newValue, forKey: Key.appAliases) }
    }

    static func setAlias(_ alias: String?, for appID: String) {
        var aliases = appAliases
        if let alias = alias, !alias.isEmpty {
            aliases[appID] = alias
        } else {
            aliases.removeValue(forKey: appID)
        }
        appAliases = aliases
    }

    static func toggleHighPriority(_ appID: String) {
        var apps = highPriorityApps
        if apps.contains(appID) {
            apps.remove(appID)
        } else {
            var low = lowPriorityApps
            low.remove(appID)
            lowPriorityApps = low
            apps.insert(appID)
        }
        highPriorityApps = apps
    }

    // MARK: - Hotkey String Conversion

    private static let keyNames: [(code: Int, name: String)] = [
        (0, "a"), (1, "s"), (2, "d"), (3, "f"), (4, "h"), (5, "g"), (6, "z"), (7, "x"),
        (8, "c"), (9, "v"), (11, "b"), (12, "q"), (13, "w"), (14, "e"), (15, "r"),
        (16, "y"), (17, "t"), (18, "1"), (19, "2"), (20, "3"), (21, "4"), (22, "6"),
        (23, "5"), (24, "="), (25, "9"), (26, "7"), (27, "-"), (28, "8"), (29, "0"),
        (30, "]"), (31, "o"), (32, "u"), (33, "["), (34, "i"), (35, "p"), (36, "return"),
        (37, "l"), (38, "j"), (39, "'"), (40, "k"), (41, ";"), (42, "\\"), (43, ","),
        (44, "/"), (45, "n"), (46, "m"), (47, "."), (48, "tab"), (49, "space"),
        (50, "`"), (51, "delete"), (53, "escape"),
        (96, "f5"), (97, "f6"), (98, "f7"), (99, "f3"), (100, "f8"), (101, "f9"),
        (103, "f11"), (105, "f13"), (107, "f14"), (109, "f10"), (111, "f12"), (113, "f15"),
        (115, "home"), (116, "pageup"), (117, "forwarddelete"), (118, "f4"), (119, "end"),
        (120, "f2"), (121, "pagedown"), (122, "f1"),
        (123, "left"), (124, "right"), (125, "down"), (126, "up"),
    ]

    private static let codeToName: [Int: String] = Dictionary(
        uniqueKeysWithValues: keyNames.map { ($0.code, $0.name) }
    )
    private static let nameToCode: [String: Int] = Dictionary(
        uniqueKeysWithValues: keyNames.map { ($0.name, $0.code) }
    )

    private static let modifierFlags: [(carbon: Int, name: String)] = [
        (4096, "control"), (2048, "option"), (512, "shift"), (256, "command"),
    ]

    private static func hotkeyToString(_ shortcut: KeyboardShortcuts.Shortcut) -> String {
        var parts: [String] = []
        for (carbon, name) in modifierFlags where shortcut.carbonModifiers & carbon != 0 {
            parts.append(name)
        }
        if let name = codeToName[shortcut.carbonKeyCode] {
            parts.append(name)
        } else {
            parts.append("keycode_\(shortcut.carbonKeyCode)")
        }
        return parts.joined(separator: "+")
    }

    private static func hotkeyFromString(_ string: String) -> KeyboardShortcuts.Shortcut? {
        let parts = string.lowercased().split(separator: "+").map(String.init)
        guard let keyPart = parts.last else { return nil }

        let modLookup = Dictionary(uniqueKeysWithValues: modifierFlags.map { ($0.name, $0.carbon) })
        var carbonMods = 0
        for part in parts.dropLast() {
            guard let flag = modLookup[part] else { return nil }
            carbonMods |= flag
        }

        let keyCode: Int
        if let code = nameToCode[keyPart] {
            keyCode = code
        } else if keyPart.hasPrefix("keycode_"), let code = Int(keyPart.dropFirst(8)) {
            keyCode = code
        } else {
            return nil
        }

        return KeyboardShortcuts.Shortcut(carbonKeyCode: keyCode, carbonModifiers: carbonMods)
    }

    // MARK: - Import / Export / Reset

    private static let hotkeyKey = "hotkey"

    static func exportAll(launchAtLogin: Bool) -> Data? {
        var dict: [String: Any] = [
            Key.launchAtLogin: launchAtLogin,
            Key.maxResults: maxResults,
            Key.fontSize: Int(fontSize),
            Key.calculatorEnabled: calculatorEnabled,
            Key.fuzzySearch: fuzzySearch,
            Key.lowPriorityApps: lowPriorityApps.sorted(),
            Key.highPriorityApps: highPriorityApps.sorted(),
            Key.appAliases: appAliases,
        ]
        if let shortcut = KeyboardShortcuts.getShortcut(for: .toggleSearch) {
            dict[hotkeyKey] = hotkeyToString(shortcut)
        }
        return try? JSONSerialization.data(
            withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]
        )
    }

    /// Imports settings from JSON data. Returns the launchAtLogin value if present
    /// (caller must apply it via SMAppService).
    @discardableResult
    static func importFrom(_ data: Data) throws -> Bool? {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(
                domain: "Preferences", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid JSON — expected a dictionary"]
            )
        }

        if let v = dict[Key.maxResults] as? Int { maxResults = v }
        if let v = dict[Key.fontSize] as? Int { fontSize = CGFloat(v) }
        if let v = dict[Key.calculatorEnabled] as? Bool { calculatorEnabled = v }
        if let v = dict[Key.fuzzySearch] as? Bool { fuzzySearch = v }

        if let arr = dict[Key.lowPriorityApps] as? [String] {
            for appID in arr where !lowPriorityApps.contains(appID) {
                toggleLowPriority(appID)
            }
        }

        if let arr = dict[Key.highPriorityApps] as? [String] {
            for appID in arr where !highPriorityApps.contains(appID) {
                toggleHighPriority(appID)
            }
        }

        if let aliases = dict[Key.appAliases] as? [String: String] {
            for (appID, alias) in aliases {
                setAlias(alias, for: appID)
            }
        }

        if let str = dict[hotkeyKey] as? String, let shortcut = hotkeyFromString(str) {
            KeyboardShortcuts.setShortcut(shortcut, for: .toggleSearch)
        }

        return dict[Key.launchAtLogin] as? Bool
    }

    static func resetAll() {
        // Scalar settings — remove so registerDefaults() takes effect
        defaults.removeObject(forKey: Key.maxResults)
        defaults.removeObject(forKey: Key.fontSize)
        defaults.removeObject(forKey: Key.calculatorEnabled)
        defaults.removeObject(forKey: Key.fuzzySearch)

        // Collection settings — write empty values explicitly
        lowPriorityApps = []
        highPriorityApps = []
        appAliases = [:]

        registerDefaults()
        KeyboardShortcuts.reset(.toggleSearch)
    }
}
