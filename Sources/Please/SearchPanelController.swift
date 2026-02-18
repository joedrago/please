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

    private static let panelWidth: CGFloat = 680
    private static let headerHeight: CGFloat = 110
    private static let rowHeight: CGFloat = 40

    private var panelHeight: CGFloat {
        Self.headerHeight + CGFloat(Preferences.maxResults) * Self.rowHeight
    }

    func show() {
        viewModel.reset()

        if panel == nil {
            createPanel()
        }

        guard let panel else { return }

        let size = NSSize(width: Self.panelWidth, height: panelHeight)
        panel.setContentSize(size)
        if let effectView = panel.contentView as? NSVisualEffectView {
            effectView.maskImage = Self.roundedMask(size: size, radius: 20)
        }
        panel.invalidateShadow()
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
        let panelRect = NSRect(x: 0, y: 0, width: Self.panelWidth, height: panelHeight)
        let newPanel = SearchPanel(contentRect: panelRect)
        newPanel.delegate = self

        let effectView = NSVisualEffectView(frame: panelRect)
        effectView.material = .hudWindow
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        effectView.wantsLayer = true
        effectView.layer?.cornerRadius = 20
        effectView.layer?.masksToBounds = true
        effectView.maskImage = Self.roundedMask(size: panelRect.size, radius: 20)

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

    private static func roundedMask(size: NSSize, radius: CGFloat) -> NSImage {
        NSImage(size: size, flipped: false) { rect in
            NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
            return true
        }
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
