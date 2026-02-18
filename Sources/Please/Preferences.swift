import Foundation

enum Preferences {
    private static let defaults = UserDefaults.standard

    enum Key {
        static let maxResults = "maxResults"
        static let fontSize = "fontSize"
        static let calculatorEnabled = "calculatorEnabled"
    }

    static func registerDefaults() {
        defaults.register(defaults: [
            Key.maxResults: 5,
            Key.fontSize: 16,
            Key.calculatorEnabled: false,
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
}
