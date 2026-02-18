import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem
    private var onOpen: () -> Void
    private var onSettings: () -> Void

    init(onOpen: @escaping () -> Void, onSettings: @escaping () -> Void) {
        self.onOpen = onOpen
        self.onSettings = onSettings
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupButton()
        setupMenu()
    }

    private func setupButton() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(
            systemSymbolName: "text.magnifyingglass",
            accessibilityDescription: "Please"
        )
    }

    private func setupMenu() {
        let menu = NSMenu()

        let openItem = NSMenuItem(title: "Open...", action: #selector(openAction), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(settingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit Please",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func openAction() {
        onOpen()
    }

    @objc private func settingsAction() {
        onSettings()
    }
}
