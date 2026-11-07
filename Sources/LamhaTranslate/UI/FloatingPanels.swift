import AppKit
import SwiftUI

public final class NonActivatingPanel: NSPanel {
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { false }
}

@MainActor
public final class FloatingPanelController: ObservableObject {
    public static let shared = FloatingPanelController()

    private var badgePanel: NonActivatingPanel?
    public private(set) var popupPanel: NonActivatingPanel?
    private var autoDismissTimer: Timer?

    private var currentSelectedText: String = ""
    private var currentAnchorPoint: NSPoint = .zero

    public var onRequestOpenSettings: (() -> Void)?

    private init() {}

    public func isPointInsidePanels(_ screenPoint: NSPoint) -> Bool {
        if let badge = badgePanel, badge.isVisible, badge.frame.insetBy(dx: -8, dy: -8).contains(screenPoint) {
            return true
        }
        if let popup = popupPanel, popup.isVisible, popup.frame.insetBy(dx: -8, dy: -8).contains(screenPoint) {
            return true
        }
        return false
    }

    public func handleTextSelection(text: String, at screenPoint: NSPoint) {
        let settings = AppSettings.shared
        currentSelectedText = text
        currentAnchorPoint = screenPoint

        // Pre-fetch translation immediately so clicking/hovering the badge opens in 0ms
        TranslationService.shared.prefetch(text: text)

        switch settings.triggerMode {
        case .instantTranslate:
            hideBadge()
            showTranslationPopup(for: text, at: screenPoint)
        case .showIconClick, .showIconHover:
            hidePopup()
            showTriggerBadge(at: screenPoint)
        }
    }

    public func showTriggerBadge(at cursorPoint: NSPoint) {
        autoDismissTimer?.invalidate()

        let settings = AppSettings.shared
        let badgeSize = CGFloat(settings.badgeSize) + 12
        let offset = settings.badgePosition.offset

        let panel: NonActivatingPanel
        if let existing = badgePanel {
            panel = existing
        } else {
            panel = NonActivatingPanel(
                contentRect: NSRect(x: 0, y: 0, width: badgeSize, height: badgeSize),
                styleMask: [.nonactivatingPanel, .borderless],
                backing: .buffered,
                defer: false
            )
            panel.isFloatingPanel = true
            panel.level = .popUpMenu
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
            badgePanel = panel
        }

        let badgeView = TriggerBadgeView { [weak self] in
            guard let self else { return }
            let textToTranslate = self.currentSelectedText
            let point = self.currentAnchorPoint
            self.hideBadge()
            self.showTranslationPopup(for: textToTranslate, at: point)
        }

        let isDarkBadge: Bool = {
            switch settings.themeMode {
            case .system: return Surfaces.currentSystemColorScheme == .dark
            case .darkGlass: return true
            case .lightGlass: return false
            }
        }()
        panel.appearance = NSAppearance(named: isDarkBadge ? .darkAqua : .aqua)
        panel.contentView = NSHostingView(rootView: badgeView)

        var targetOrigin = NSPoint(
            x: cursorPoint.x + offset.x,
            y: cursorPoint.y + offset.y
        )
        targetOrigin = clampFrameOrigin(
            origin: targetOrigin,
            size: NSSize(width: badgeSize, height: badgeSize),
            near: cursorPoint
        )

        panel.setFrame(NSRect(origin: targetOrigin, size: NSSize(width: badgeSize, height: badgeSize)), display: true)
        panel.orderFrontRegardless()

        autoDismissTimer = Timer.scheduledTimer(withTimeInterval: settings.autoDismissSeconds, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.hideBadge()
            }
        }
    }

    public func showTranslationPopup(for text: String, at anchorPoint: NSPoint) {
        autoDismissTimer?.invalidate()
        hideBadge()

        currentAnchorPoint = anchorPoint

        let panel: NonActivatingPanel
        if let existing = popupPanel {
            panel = existing
        } else {
            panel = NonActivatingPanel(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 120),
                styleMask: [.nonactivatingPanel, .borderless],
                backing: .buffered,
                defer: false
            )
            panel.isFloatingPanel = true
            panel.level = .popUpMenu
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            panel.isMovableByWindowBackground = true
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
            popupPanel = panel
        }

        let popupView = TranslationPopupView(
            sourceText: text,
            onClose: { [weak self] in
                self?.hideAll()
            },
            onOpenSettings: { [weak self] in
                self?.onRequestOpenSettings?()
            },
            onResizeNeeded: { [weak self] exactCardSize in
                self?.applyExactCardSize(exactCardSize)
            }
        )
        .padding(Space.md)

        let isDarkPopup: Bool = {
            switch AppSettings.shared.themeMode {
            case .system: return Surfaces.currentSystemColorScheme == .dark
            case .darkGlass: return true
            case .lightGlass: return false
            }
        }()
        panel.appearance = NSAppearance(named: isDarkPopup ? .darkAqua : .aqua)

        let hostingView = NSHostingView(rootView: popupView)
        hostingView.sizingOptions = [.intrinsicContentSize]
        panel.contentView = hostingView

        hostingView.layoutSubtreeIfNeeded()
        let initialSize = NSSize(
            width: max(hostingView.fittingSize.width, 160),
            height: max(hostingView.fittingSize.height, 64)
        )

        let initialOrigin = clampFrameOrigin(
            origin: NSPoint(
                x: anchorPoint.x - (initialSize.width * 0.35),
                y: anchorPoint.y - initialSize.height - 12
            ),
            size: initialSize,
            near: anchorPoint
        )

        panel.setFrame(NSRect(origin: initialOrigin, size: initialSize), display: true)
        panel.orderFrontRegardless()
    }

    private func applyExactCardSize(_ cardSize: CGSize) {
        guard let panel = popupPanel, panel.isVisible, cardSize.width > 20, cardSize.height > 20 else { return }

        let shadowPad = Space.md * 2
        let newSize = NSSize(
            width: ceil(cardSize.width + shadowPad),
            height: ceil(cardSize.height + shadowPad)
        )

        let oldFrame = panel.frame
        if abs(oldFrame.width - newSize.width) < 1 && abs(oldFrame.height - newSize.height) < 1 {
            return
        }

        var newOrigin = NSPoint(
            x: oldFrame.origin.x,
            y: oldFrame.maxY - newSize.height
        )
        newOrigin = clampFrameOrigin(origin: newOrigin, size: newSize, near: currentAnchorPoint)
        panel.setFrame(NSRect(origin: newOrigin, size: newSize), display: true, animate: false)
    }

    public func hideBadge() {
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        badgePanel?.orderOut(nil)
    }

    public func hidePopup() {
        SpeechService.shared.stop()
        popupPanel?.orderOut(nil)
    }

    public func hidePopupIfNotPinned() {
        hidePopup()
    }

    public func hideAll() {
        hideBadge()
        hidePopup()
    }

    private func clampFrameOrigin(origin: NSPoint, size: NSSize, near point: NSPoint) -> NSPoint {
        let screen = NSScreen.screens.first(where: { NSMouseInRect(point, $0.frame, false) }) ?? NSScreen.main ?? NSScreen.screens.first
        guard let visibleFrame = screen?.visibleFrame else { return origin }

        var x = origin.x
        var y = origin.y

        if x + size.width > visibleFrame.maxX - 8 {
            x = visibleFrame.maxX - size.width - 8
        }
        if x < visibleFrame.minX + 8 {
            x = visibleFrame.minX + 8
        }

        if y < visibleFrame.minY + 8 {
            y = min(point.y + 22, visibleFrame.maxY - size.height - 8)
        }
        if y + size.height > visibleFrame.maxY - 8 {
            y = visibleFrame.maxY - size.height - 8
        }

        return NSPoint(x: x, y: y)
    }
}
