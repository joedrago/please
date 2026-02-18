import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var searchPanelController: SearchPanelController?
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        searchPanelController = SearchPanelController()

        statusBarController = StatusBarController(
            onOpen: { [weak self] in
                self?.searchPanelController?.toggle()
            },
            onSettings: { [weak self] in
                self?.showSettings()
            }
        )

        HotkeyManager.setup { [weak self] in
            self?.searchPanelController?.toggle()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func showSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
