import AppKit
import ApplicationServices
import Carbon.HIToolbox

/// Global shortcut using Carbon RegisterEventHotKey (works system-wide without requiring Accessibility permissions)
public final class GlobalHotKey {
    private var ref: EventHotKeyRef?
    private var handler: EventHandlerRef?
    private let action: () -> Void

    public init(key: Int, modifiers: NSEvent.ModifierFlags, action: @escaping () -> Void) {
        self.action = action
        var carbon: UInt32 = 0
        if modifiers.contains(.command) { carbon |= UInt32(cmdKey) }
        if modifiers.contains(.option) { carbon |= UInt32(optionKey) }
        if modifiers.contains(.control) { carbon |= UInt32(controlKey) }
        if modifiers.contains(.shift) { carbon |= UInt32(shiftKey) }

        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let me = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), { _, _, data in
            guard let data else { return noErr }
            let hotKey = Unmanaged<GlobalHotKey>.fromOpaque(data).takeUnretainedValue()
            MainActor.assumeIsolated { hotKey.action() }
            return noErr
        }, 1, &spec, me, &handler)
        RegisterEventHotKey(UInt32(key), carbon, EventHotKeyID(signature: 0x4C4D_4841, id: 1), GetApplicationEventTarget(), 0, &ref)
    }

    deinit {
        if let ref { UnregisterEventHotKey(ref) }
        if let handler { RemoveEventHandler(handler) }
    }
}

@MainActor
public final class SelectionMonitor: ObservableObject {
    public static let shared = SelectionMonitor()

    @Published public var isAccessibilityTrusted: Bool = false
    @Published public var lastSelectedText: String = ""
    @Published public var lastSelectionPoint: NSPoint = .zero

    private var globalMouseMonitor: Any?
    private var globalKeyMonitor: Any?
    private var carbonHotKey: GlobalHotKey?
    private var pasteboardTimer: Timer?
    private var permissionTimer: Timer?

    private var mouseDownLocation: NSPoint = .zero
    private var mouseDownTime: Date = .distantPast
    private var dragEventCount: Int = 0
    private var isPerformingInternalCopy: Bool = false

    private var lastPasteboardChangeCount: Int = NSPasteboard.general.changeCount
    private var lastCopyTimestamp: Date = .distantPast
    private var lastCopiedString: String = ""

    public var onTextSelected: ((String, NSPoint) -> Void)?
    public var onDismissRequested: (() -> Void)?
    public var isPointInsideUI: ((NSPoint) -> Bool)?

    private init() {
        checkAccessibilityPermission(prompt: false)
    }

    public func start() {
        checkAccessibilityPermission(prompt: false)
        setupMouseMonitors()
        setupCarbonHotKey()
        setupPasteboardMonitor()
        setupPermissionPolling()
    }

    public func stop() {
        if let globalMouseMonitor {
            NSEvent.removeMonitor(globalMouseMonitor)
            self.globalMouseMonitor = nil
        }
        if let globalKeyMonitor {
            NSEvent.removeMonitor(globalKeyMonitor)
            self.globalKeyMonitor = nil
        }
        carbonHotKey = nil
        pasteboardTimer?.invalidate()
        pasteboardTimer = nil
        permissionTimer?.invalidate()
        permissionTimer = nil
    }

    @discardableResult
    public func checkAccessibilityPermission(prompt: Bool) -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: prompt]
        let trusted = AXIsProcessTrustedWithOptions(options)
        if self.isAccessibilityTrusted != trusted {
            self.isAccessibilityTrusted = trusted
        }
        return trusted
    }

    public func openAccessibilitySettings() {
        let _ = checkAccessibilityPermission(prompt: true)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    private func setupCarbonHotKey() {
        // Option (⌥) + T (kVK_ANSI_T = 17)
        carbonHotKey = GlobalHotKey(key: kVK_ANSI_T, modifiers: [.option]) { [weak self] in
            Task { @MainActor [weak self] in
                guard let self, AppSettings.shared.isEnabled else { return }
                let mouseLoc = NSEvent.mouseLocation
                if let text = await self.extractSelectedText(allowClipboardFallback: true),
                   !text.isEmpty {
                    let cleaned = Self.cleanSelectedText(text)
                    guard Self.isValidTranslatableText(cleaned) else { return }
                    self.lastSelectedText = cleaned
                    self.lastSelectionPoint = mouseLoc
                    FloatingPanelController.shared.showTranslationPopup(for: cleaned, at: mouseLoc)
                } else if let pbText = NSPasteboard.general.string(forType: .string) {
                    let cleaned = Self.cleanSelectedText(pbText)
                    guard Self.isValidTranslatableText(cleaned) else { return }
                    self.lastSelectedText = cleaned
                    self.lastSelectionPoint = mouseLoc
                    FloatingPanelController.shared.showTranslationPopup(for: cleaned, at: mouseLoc)
                }
            }
        }
    }

    private func setupPermissionPolling() {
        permissionTimer?.invalidate()
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let trusted = AXIsProcessTrusted()
                if self.isAccessibilityTrusted != trusted {
                    self.isAccessibilityTrusted = trusted
                }
            }
        }
    }

    private func setupPasteboardMonitor() {
        lastPasteboardChangeCount = NSPasteboard.general.changeCount
        pasteboardTimer?.invalidate()
        pasteboardTimer = Timer.scheduledTimer(withTimeInterval: 0.16, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkPasteboardChanges()
            }
        }
    }

    private func checkPasteboardChanges() {
        guard !isPerformingInternalCopy else { return }
        let pb = NSPasteboard.general
        let currentCount = pb.changeCount
        guard currentCount != lastPasteboardChangeCount else { return }
        lastPasteboardChangeCount = currentCount

        guard AppSettings.shared.isEnabled, AppSettings.shared.doubleCopyTranslate else { return }
        guard let copied = pb.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !copied.isEmpty,
              copied.count <= 4000 else {
            return
        }

        let now = Date()
        let delta = now.timeIntervalSince(lastCopyTimestamp)
        lastCopyTimestamp = now

        // Double Cmd+C within 0.85 seconds triggers translation at current mouse location
        if delta < 0.85 && copied == lastCopiedString {
            let mouseLoc = NSEvent.mouseLocation
            lastSelectedText = copied
            lastSelectionPoint = mouseLoc
            TranslationService.shared.prefetch(text: copied)
            FloatingPanelController.shared.showTranslationPopup(for: copied, at: mouseLoc)
        }
        lastCopiedString = copied
    }

    private func setupMouseMonitors() {
        if let globalMouseMonitor {
            NSEvent.removeMonitor(globalMouseMonitor)
        }

        let eventMask: NSEvent.EventTypeMask = [
            .leftMouseDown,
            .leftMouseDragged,
            .leftMouseUp,
            .rightMouseDown,
            .otherMouseDown,
            .scrollWheel,
            .keyDown
        ]

        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleGlobalEvent(event)
            }
        }

        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            Task { @MainActor [weak self] in
                if event.keyCode == 53 {
                    self?.onDismissRequested?()
                }
            }
        }
    }

    private func handleGlobalEvent(_ event: NSEvent) {
        let mouseLoc = NSEvent.mouseLocation

        switch event.type {
        case .leftMouseDown:
            mouseDownLocation = mouseLoc
            mouseDownTime = Date()
            dragEventCount = 0

            if AXIsProcessTrusted() {
                isAccessibilityTrusted = true
                enableManualAccessibilityOnFrontmostApp()
            }

            if !(isPointInsideUI?(mouseLoc) ?? false) {
                onDismissRequested?()
            }

        case .rightMouseDown, .otherMouseDown:
            if !(isPointInsideUI?(mouseLoc) ?? false) {
                onDismissRequested?()
            }

        case .scrollWheel:
            if !(isPointInsideUI?(mouseLoc) ?? false) {
                if abs(event.scrollingDeltaY) > 4 || abs(event.scrollingDeltaX) > 4 {
                    onDismissRequested?()
                }
            }

        case .leftMouseDragged:
            dragEventCount += 1

        case .leftMouseUp:
            handleMouseUp(event: event, mouseUpLocation: mouseLoc)

        default:
            break
        }
    }

    private func handleMouseUp(event: NSEvent, mouseUpLocation: NSPoint) {
        let settings = AppSettings.shared
        guard settings.isEnabled else { return }

        if isPointInsideUI?(mouseUpLocation) ?? false {
            return
        }

        if let frontApp = NSWorkspace.shared.frontmostApplication {
            if frontApp.processIdentifier == ProcessInfo.processInfo.processIdentifier {
                return
            }
            if let bundleID = frontApp.bundleIdentifier,
               settings.excludedBundleIDs.contains(bundleID) {
                return
            }
        }

        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        switch settings.modifierRequirement {
        case .none:
            break
        case .option:
            guard flags.contains(.option) else { return }
        case .command:
            guard flags.contains(.command) else { return }
        case .control:
            guard flags.contains(.control) else { return }
        }

        let distance = hypot(mouseUpLocation.x - mouseDownLocation.x, mouseUpLocation.y - mouseDownLocation.y)
        let isDragSelection = (dragEventCount >= 1 && distance > 3.5)
        let isMultiClickSelection = (event.clickCount >= 2)
        let isShiftClickSelection = flags.contains(.shift)

        guard isDragSelection || isMultiClickSelection || isShiftClickSelection else {
            return
        }

        let capturedMouseUpPoint = mouseUpLocation
        let capturedDragCount = dragEventCount
        let capturedClickCount = event.clickCount

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 10_000_000)

            let shouldTryFallback = settings.smartClipboardFallback && (capturedClickCount >= 2 || capturedDragCount >= 1)
            if let rawText = await self.extractSelectedText(allowClipboardFallback: shouldTryFallback) {
                let cleaned = Self.cleanSelectedText(rawText)
                guard Self.isValidTranslatableText(cleaned) else { return }

                self.lastSelectedText = cleaned
                self.lastSelectionPoint = capturedMouseUpPoint
                self.onTextSelected?(cleaned, capturedMouseUpPoint)
            }
        }
    }

    public func extractSelectedText(allowClipboardFallback: Bool) async -> String? {
        let trusted = AXIsProcessTrusted()
        self.isAccessibilityTrusted = trusted

        if trusted {
            enableManualAccessibilityOnFrontmostApp()

            if let axText = readSelectedTextViaAX(),
               !axText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return axText
            }

            if let elementAtMouseText = readSelectedTextAtMousePosition(),
               !elementAtMouseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return elementAtMouseText
            }
        }

        if trusted && allowClipboardFallback {
            if !isFocusedElementNonTextControl() {
                if let copiedText = await simulateCopyAndRestorePasteboard(),
                   !copiedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return copiedText
                }
            }
        }

        return nil
    }

    private func enableManualAccessibilityOnFrontmostApp() {
        guard let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier else { return }
        let appElement = AXUIElementCreateApplication(pid)
        AXUIElementSetAttributeValue(appElement, "AXManualAccessibility" as CFString, kCFBooleanTrue)
        AXUIElementSetAttributeValue(appElement, "AXEnhancedUserInterface" as CFString, kCFBooleanTrue)
    }

    private func readSelectedTextViaAX() -> String? {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedElement: CFTypeRef?
        let status = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement)

        if status == .success, let element = focusedElement {
            let axElement = element as! AXUIElement
            if let text = extractSelectedString(from: axElement) {
                return text
            }
        }

        if let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier {
            let appElement = AXUIElementCreateApplication(pid)
            var appFocused: CFTypeRef?
            if AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &appFocused) == .success,
               let element = appFocused {
                let axElement = element as! AXUIElement
                if let text = extractSelectedString(from: axElement) {
                    return text
                }
            }
        }

        return nil
    }

    private func extractSelectedString(from element: AXUIElement) -> String? {
        if let direct = copyStringAttribute(from: element, attribute: kAXSelectedTextAttribute as String) {
            return direct
        }
        // Fallback for PDFKit / WebKit / Cocoa views that expose kAXSelectedTextRangeAttribute
        var selectedRangeRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &selectedRangeRef) == .success,
           let rangeVal = selectedRangeRef {
            var strForRangeRef: CFTypeRef?
            if AXUIElementCopyParameterizedAttributeValue(
                element,
                kAXStringForRangeParameterizedAttribute as CFString,
                rangeVal,
                &strForRangeRef
            ) == .success,
               let str = strForRangeRef as? String,
               !str.isEmpty {
                return str
            }
        }
        return nil
    }

    private func readSelectedTextAtMousePosition() -> String? {
        let mouseLoc = NSEvent.mouseLocation
        guard let primaryScreen = NSScreen.screens.first else { return nil }
        let flippedY = primaryScreen.frame.height - mouseLoc.y

        let systemWide = AXUIElementCreateSystemWide()
        var hitElement: AXUIElement?
        let err = AXUIElementCopyElementAtPosition(systemWide, Float(mouseLoc.x), Float(flippedY), &hitElement)
        if err == .success, let element = hitElement {
            if let text = extractSelectedString(from: element) {
                return text
            }
        }
        return nil
    }

    private func isFocusedElementNonTextControl() -> Bool {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedElement: CFTypeRef?
        guard AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement) == .success,
              let element = focusedElement else {
            return false
        }
        let axElement = element as! AXUIElement
        if let role = copyStringAttribute(from: axElement, attribute: kAXRoleAttribute as String) {
            let nonTextRoles: Set<String> = [
                "AXSlider", "AXScrollBar", "AXSplitter", "AXGrowArea",
                "AXToolbar", "AXMenuBar", "AXMenu", "AXMenuItem", "AXDockItem"
            ]
            return nonTextRoles.contains(role)
        }
        return false
    }

    private func copyStringAttribute(from element: AXUIElement, attribute: String) -> String? {
        var value: CFTypeRef?
        let err = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
        if err == .success, let str = value as? String, !str.isEmpty {
            return str
        }
        return nil
    }

    private func simulateCopyAndRestorePasteboard() async -> String? {
        isPerformingInternalCopy = true
        defer {
            isPerformingInternalCopy = false
            lastPasteboardChangeCount = NSPasteboard.general.changeCount
        }

        let pasteboard = NSPasteboard.general
        let initialChangeCount = pasteboard.changeCount

        var savedItems: [[NSPasteboard.PasteboardType: Data]] = []
        if let items = pasteboard.pasteboardItems {
            for item in items {
                var itemDict: [NSPasteboard.PasteboardType: Data] = [:]
                for type in item.types {
                    if let data = item.data(forType: type) {
                        itemDict[type] = data
                    }
                }
                if !itemDict.isEmpty {
                    savedItems.append(itemDict)
                }
            }
        }

        guard let source = CGEventSource(stateID: .combinedSessionState),
              let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(8), keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(8), keyDown: false) else {
            return nil
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)

        for _ in 0..<9 {
            try? await Task.sleep(nanoseconds: 6_000_000)
            if pasteboard.changeCount != initialChangeCount {
                break
            }
        }

        guard pasteboard.changeCount != initialChangeCount else {
            return nil
        }

        let capturedText = pasteboard.string(forType: .string)

        pasteboard.clearContents()
        if !savedItems.isEmpty {
            var restoredObjects: [NSPasteboardItem] = []
            for itemDict in savedItems {
                let newItem = NSPasteboardItem()
                for (type, data) in itemDict {
                    newItem.setData(data, forType: type)
                }
                restoredObjects.append(newItem)
            }
            pasteboard.writeObjects(restoredObjects)
        }

        return capturedText
    }

    private static func cleanSelectedText(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func isValidTranslatableText(_ text: String) -> Bool {
        guard text.count >= 1, text.count <= 3500 else { return false }
        return text.unicodeScalars.contains { CharacterSet.letters.contains($0) }
    }
}
