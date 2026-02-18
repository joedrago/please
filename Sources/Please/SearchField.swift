import AppKit
import SwiftUI

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var onMoveUp: () -> Void
    var onMoveDown: () -> Void
    var onSubmit: () -> Void
    var onEscape: () -> Void

    func makeNSView(context: Context) -> PleaseSearchTextField {
        let field = PleaseSearchTextField()
        field.delegate = context.coordinator
        field.placeholderString = "Search applications..."
        field.font = NSFont.systemFont(ofSize: 20)
        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.textColor = .white
        field.cell?.sendsActionOnEndEditing = false
        field.onMoveUp = onMoveUp
        field.onMoveDown = onMoveDown
        field.onSubmit = onSubmit
        field.onEscape = onEscape

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.panelDidAppear),
            name: .searchPanelDidAppear,
            object: nil
        )

        return field
    }

    func updateNSView(_ nsView: PleaseSearchTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        nsView.onMoveUp = onMoveUp
        nsView.onMoveDown = onMoveDown
        nsView.onSubmit = onSubmit
        nsView.onEscape = onEscape
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: SearchField

        init(_ parent: SearchField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            parent.text = field.stringValue
        }

        @objc func panelDidAppear() {
            DispatchQueue.main.async { [weak self] in
                guard let coordinator = self else { return }
                // Find the text field in the responder chain
                if let window = NSApp.keyWindow {
                    window.makeFirstResponder(
                        coordinator.findSearchField(in: window.contentView)
                    )
                }
            }
        }

        private func findSearchField(in view: NSView?) -> PleaseSearchTextField? {
            guard let view else { return nil }
            if let field = view as? PleaseSearchTextField {
                return field
            }
            for subview in view.subviews {
                if let found = findSearchField(in: subview) {
                    return found
                }
            }
            return nil
        }
    }
}

class PleaseSearchTextField: NSTextField {
    var onMoveUp: (() -> Void)?
    var onMoveDown: (() -> Void)?
    var onSubmit: (() -> Void)?
    var onEscape: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 125: // Down arrow
            onMoveDown?()
        case 126: // Up arrow
            onMoveUp?()
        case 36: // Return
            onSubmit?()
        case 53: // Escape
            onEscape?()
        default:
            super.keyDown(with: event)
        }
    }
}
