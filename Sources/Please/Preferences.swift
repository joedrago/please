import Foundation

enum Preferences {
    private static let defaults = UserDefaults.standard

    enum Key {
        static let maxResults = "maxResults"
        static let fontSize = "fontSize"
        static let calculatorEnabled = "calculatorEnabled"
        static let fuzzySearch = "fuzzySearch"
        static let lowPriorityApps = "lowPriorityApps"
        static let highPriorityApps = "highPriorityApps"
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
}
