import AppKit
import SwiftUI
import Combine

@main
@MainActor
public final class LamhaApp: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var settingsWindow: NSWindow?
    private var cancellables: Set<AnyCancellable> = []

    public static func main() {
        let app = NSApplication.shared
        let delegate = LamhaApp()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        TranslationService.shared.warmUpConnection()
        setupStatusBarItem()
        observeSettingsChanges()
        setupSelectionMonitor()
        openSettingsWindow()
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openSettingsWindow()
        return true
    }

    private func observeSettingsChanges() {
        AppSettings.shared.$appLanguage
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.settingsWindow?.title = AppSettings.shared.strings.appName
            }
            .store(in: &cancellables)

        AppSettings.shared.$isEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.statusItem?.button?.image = LamhaMenuBarIcon.make(isEnabled: enabled)
            }
            .store(in: &cancellables)
    }

    private func setupStatusBarItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = LamhaMenuBarIcon.make(isEnabled: AppSettings.shared.isEnabled)
            button.action = #selector(toggleStatusPopover(_:))
            button.target = self
        }
        self.statusItem = item

        let pop = NSPopover()
        pop.contentSize = NSSize(width: 345, height: 64)
        pop.behavior = .transient
        pop.contentViewController = NSHostingController(
            rootView: MenuBarView(onOpenSettings: { [weak self] in
                self?.popover?.performClose(nil)
                self?.openSettingsWindow()
            })
        )
        self.popover = pop
    }

    @objc private func toggleStatusPopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button, let popover = self.popover else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
            popover.contentViewController?.view.window?.makeFirstResponder(nil)
        }
    }

    private func setupSelectionMonitor() {
        let monitor = SelectionMonitor.shared
        let panels = FloatingPanelController.shared

        panels.onRequestOpenSettings = { [weak self] in
            self?.openSettingsWindow()
        }

        monitor.isPointInsideUI = { point in
            panels.isPointInsidePanels(point)
        }

        monitor.onTextSelected = { text, screenPoint in
            panels.handleTextSelection(text: text, at: screenPoint)
        }

        monitor.onDismissRequested = {
            panels.hideBadge()
            panels.hidePopup()
        }

        monitor.start()
    }

    public func openSettingsWindow() {
        if let existing = settingsWindow {
            NSApp.activate(ignoringOtherApps: true)
            existing.makeKeyAndOrderFront(nil)
            DispatchQueue.main.async {
                existing.makeFirstResponder(nil)
            }
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 580),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = AppSettings.shared.strings.appName
        window.center()
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: SettingsView())

        self.settingsWindow = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        DispatchQueue.main.async {
            window.makeFirstResponder(nil)
        }
    }
}
