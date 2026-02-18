import AppKit
import SwiftUI

class SearchPanelController: NSObject, NSWindowDelegate {
    private var panel: SearchPanel?
    private var viewModel = SearchViewModel()
    private var isShowing = false

    func toggle() {
        if isShowing {
            hide()
        } else {
            show()
        }
    }

    func show() {
        viewModel.reset()

        if panel == nil {
            createPanel()
        }

        guard let panel else { return }

        positionPanel(panel)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isShowing = true

        // Post notification so SearchField can grab focus
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .searchPanelDidAppear, object: nil)
        }
    }

    func hide() {
        guard isShowing else { return }
        panel?.orderOut(nil)
        isShowing = false
    }

    // MARK: - NSWindowDelegate

    func windowDidResignKey(_ notification: Notification) {
        hide()
    }

    private func createPanel() {
        let panelRect = NSRect(x: 0, y: 0, width: 680, height: 400)
        let newPanel = SearchPanel(contentRect: panelRect)
        newPanel.delegate = self

        let effectView = NSVisualEffectView(frame: panelRect)
        effectView.material = .hudWindow
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        effectView.wantsLayer = true
        effectView.layer?.cornerRadius = 12
        effectView.layer?.masksToBounds = true

        let rootView = SearchView(viewModel: viewModel) { [weak self] in
            self?.hide()
        }
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = panelRect
        hostingView.autoresizingMask = [.width, .height]

        effectView.addSubview(hostingView)
        newPanel.contentView = effectView

        panel = newPanel
    }

    private func positionPanel(_ panel: SearchPanel) {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let x = screenFrame.midX - panelSize.width / 2
        let y = screenFrame.midY - panelSize.height / 2 + screenFrame.height * 0.1
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

extension Notification.Name {
    static let searchPanelDidAppear = Notification.Name("searchPanelDidAppear")
}
