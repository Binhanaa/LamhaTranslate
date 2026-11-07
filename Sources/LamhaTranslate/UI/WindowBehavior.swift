import AppKit
import SwiftUI

extension View {
    /// Opens the window with nothing focused and disables focus rings across all AppKit controls.
    public func noInitialFocus() -> some View {
        background(WindowFocusSuppressor())
    }
}

private struct WindowFocusSuppressor: NSViewRepresentable {
    func makeNSView(context: Context) -> FocusGuardView {
        FocusGuardView()
    }

    func updateNSView(_ nsView: FocusGuardView, context: Context) {
        nsView.suppressFocusRings()
    }

    final class FocusGuardView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard let window else { return }
            NotificationCenter.default.removeObserver(self)
            clearAndSuppress(window)

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleWindowEvent(_:)),
                name: NSWindow.didBecomeKeyNotification,
                object: window
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleWindowEvent(_:)),
                name: NSWindow.didUpdateNotification,
                object: window
            )
        }

        @objc private func handleWindowEvent(_ note: Notification) {
            suppressFocusRings()
        }

        func suppressFocusRings() {
            guard let contentView = window?.contentView else { return }
            disableFocusRingRecursively(in: contentView)
            if !(window?.firstResponder is NSTextView) {
                window?.makeFirstResponder(nil)
            }
        }

        private func clearAndSuppress(_ window: NSWindow) {
            DispatchQueue.main.async { [weak self, weak window] in
                guard let window else { return }
                window.makeFirstResponder(nil)
                if let root = window.contentView {
                    self?.disableFocusRingRecursively(in: root)
                }
            }
        }

        private func disableFocusRingRecursively(in view: NSView) {
            if view.focusRingType != .none {
                view.focusRingType = .none
            }
            for subview in view.subviews {
                disableFocusRingRecursively(in: subview)
            }
        }
    }
}
