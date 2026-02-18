import AppKit

enum AppLauncher {
    static func launch(_ app: AppInfo) {
        NSWorkspace.shared.openApplication(
            at: app.path,
            configuration: NSWorkspace.OpenConfiguration()
        ) { _, error in
            if let error {
                NSLog("Failed to launch \(app.name): \(error.localizedDescription)")
            }
        }
    }
}
