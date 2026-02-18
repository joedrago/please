import AppKit

enum AppFinder {
    static func findApplications() -> [AppInfo] {
        let fileManager = FileManager.default
        var apps: [String: AppInfo] = [:]

        let searchPaths = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Applications"),
        ]

        for basePath in searchPaths {
            guard let contents = try? fileManager.contentsOfDirectory(
                at: basePath,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }

            for url in contents {
                if url.pathExtension == "app" {
                    if let info = appInfo(from: url) {
                        apps[info.id] = info
                    }
                } else {
                    // Check one level of subdirectories (e.g. Utilities/)
                    var isDir: ObjCBool = false
                    if fileManager.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                        if let subContents = try? fileManager.contentsOfDirectory(
                            at: url,
                            includingPropertiesForKeys: nil,
                            options: [.skipsHiddenFiles]
                        ) {
                            for subURL in subContents where subURL.pathExtension == "app" {
                                if let info = appInfo(from: subURL) {
                                    apps[info.id] = info
                                }
                            }
                        }
                    }
                }
            }
        }

        return Array(apps.values).sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private static func appInfo(from url: URL) -> AppInfo? {
        guard let bundle = Bundle(url: url) else { return nil }

        let name = bundle.infoDictionary?["CFBundleDisplayName"] as? String
            ?? bundle.infoDictionary?["CFBundleName"] as? String
            ?? url.deletingPathExtension().lastPathComponent

        let icon = NSWorkspace.shared.icon(forFile: url.path)
        icon.size = NSSize(width: 32, height: 32)

        return AppInfo(
            name: name,
            path: url,
            bundleIdentifier: bundle.bundleIdentifier,
            icon: icon
        )
    }
}
