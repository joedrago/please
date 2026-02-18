import AppKit

struct AppInfo: Identifiable, Hashable {
    let id: String // bundleIdentifier or path
    let name: String
    let path: URL
    let bundleIdentifier: String?
    let icon: NSImage

    init(name: String, path: URL, bundleIdentifier: String?, icon: NSImage) {
        id = bundleIdentifier ?? path.path
        self.name = name
        self.path = path
        self.bundleIdentifier = bundleIdentifier
        self.icon = icon
    }

    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
