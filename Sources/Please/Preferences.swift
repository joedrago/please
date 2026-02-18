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

    // MARK: - Import / Export / Reset

    static func exportAll(launchAtLogin: Bool) -> Data? {
        let dict: [String: Any] = [
            Key.launchAtLogin: launchAtLogin,
            Key.maxResults: maxResults,
            Key.fontSize: Int(fontSize),
            Key.calculatorEnabled: calculatorEnabled,
            Key.fuzzySearch: fuzzySearch,
            Key.lowPriorityApps: lowPriorityApps.sorted(),
            Key.highPriorityApps: highPriorityApps.sorted(),
            Key.appAliases: appAliases,
        ]
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
