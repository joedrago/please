import AppKit

enum AppLauncher {
    static func launch(_ app: AppInfo) {
        // Try to activate if already running
        if let bundleID = app.bundleIdentifier,
           let running = NSRunningApplication.runningApplications(
               withBundleIdentifier: bundleID
           ).first
        {
            running.activate()
            return
        }

        // Otherwise launch the app
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
