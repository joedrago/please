import Foundation

enum Preferences {
    private static let defaults = UserDefaults.standard

    enum Key {
        static let maxResults = "maxResults"
        static let fontSize = "fontSize"
    }

    static func registerDefaults() {
        defaults.register(defaults: [
            Key.maxResults: 5,
            Key.fontSize: 16,
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
}
