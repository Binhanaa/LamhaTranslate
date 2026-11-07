import SwiftUI
import AppKit

@MainActor
private final class DropdownMenuActionTarget: NSObject {
    static let shared = DropdownMenuActionTarget()
    var onSelectIndex: ((Int) -> Void)?

    @objc func selectItem(_ sender: NSMenuItem) {
        onSelectIndex?(sender.tag)
    }
}

public struct DropdownOption<Value: Hashable>: Identifiable {
    public let id = UUID()
    public let value: Value
    public let label: String

    public init(value: Value, label: String) {
        self.value = value
        self.label = label
    }
}

/// Custom native-styled dropdown control that guarantees 100% RTL right-alignment in Arabic and LTR left-alignment in English.
public struct LamhaDropdown<Value: Hashable>: View {
    @Binding var selection: Value
    let options: [DropdownOption<Value>]
    let isRTL: Bool
    let width: CGFloat

    @State private var isHovered: Bool = false

    public init(
        selection: Binding<Value>,
        options: [DropdownOption<Value>],
        isRTL: Bool,
        width: CGFloat = 235
    ) {
        self._selection = selection
        self.options = options
        self.isRTL = isRTL
        self.width = width
    }

    private var selectedLabel: String {
        options.first(where: { $0.value == selection })?.label ?? ""
    }

    public var body: some View {
        Button(action: openNativeMenu) {
            HStack(spacing: Space.sm) {
                Text(selectedLabel)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: Space.xs)

                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Palette.accent)
                        .frame(width: 17, height: 17)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Palette.onAccent)
                }
            }
            .padding(.horizontal, Space.sm + 2)
            .padding(.vertical, 5)
            .frame(width: width)
            .background(
                RoundedRectangle(cornerRadius: Radius.xs + 1, style: .continuous)
                    .fill(Color.primary.opacity(isHovered ? 0.11 : 0.075))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.xs + 1, style: .continuous)
                            .strokeBorder(Surfaces.hairline, lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    private func openNativeMenu() {
        let menu = NSMenu()
        menu.userInterfaceLayoutDirection = isRTL ? .rightToLeft : .leftToRight

        let target = DropdownMenuActionTarget.shared
        target.onSelectIndex = { idx in
            guard idx >= 0 && idx < options.count else { return }
            selection = options[idx].value
        }

        for (index, opt) in options.enumerated() {
            let item = NSMenuItem(
                title: opt.label,
                action: #selector(DropdownMenuActionTarget.selectItem(_:)),
                keyEquivalent: ""
            )
            item.target = target
            item.tag = index
            item.state = (opt.value == selection) ? .on : .off
            menu.addItem(item)
        }

        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }
}

public struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var monitor = SelectionMonitor.shared

    @State private var searchQuery: String = ""
    @State private var testSampleText: String = "Select any text anywhere on your Mac to translate it instantly."

    public init() {}

    private var s: AppStrings { settings.strings }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Brand Header (Clean: Brand Icon + Title on leading, Active Toggle on trailing)
            HStack(spacing: Space.md) {
                LamhaBrandIconView(size: 44)

                VStack(alignment: .leading, spacing: Space.xxs) {
                    HStack(spacing: Space.sm) {
                        Text(s.appName)
                            .font(.system(size: 15.5, weight: .bold))
                        Text("v1.2")
                            .font(.system(size: 10.5, weight: .semibold))
                            .padding(.horizontal, Space.sm)
                            .padding(.vertical, Space.xxs)
                            .background(Capsule().fill(Palette.accent.opacity(0.16)))
                            .foregroundStyle(Palette.accentText)
                    }
                    Text(s.appTagline)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Master Enable Switch
                Toggle(isOn: $settings.isEnabled) {
                    Text(settings.isEnabled ? s.enabled : s.disabled)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(settings.isEnabled ? Palette.success : .secondary)
                }
                .toggleStyle(.switch)
                .controlSize(.small)
            }
            .padding(.horizontal, Space.margin)
            .padding(.vertical, Space.md)
            .background(.ultraThinMaterial)

            Divider()

            // 6 Concise Single-Word Tabs (Languages, Mouse, Appearance, Features, History, Settings)
            HStack(spacing: Space.sm) {
                tabButton(index: 0, icon: "globe", title: s.tabLanguages)
                tabButton(index: 1, icon: "computermouse.fill", title: s.tabMouse)
                tabButton(index: 2, icon: "paintpalette.fill", title: s.tabAppearance)
                tabButton(index: 3, icon: "sparkles", title: s.tabFeatures)
                tabButton(index: 4, icon: "clock.arrow.circlepath", title: s.tabHistory)
                tabButton(index: 5, icon: "gearshape.fill", title: s.tabSettings)
                Spacer()
            }
            .padding(.horizontal, Space.margin)
            .padding(.vertical, Space.sm)
            .background(Color.primary.opacity(0.025))

            Divider()

            // Tab Content
            ScrollView {
                VStack(alignment: .leading, spacing: Space.lg) {
                    switch settings.selectedSettingsTab {
                    case 0:
                        languagesTab
                    case 1:
                        mouseAndTriggerTab
                    case 2:
                        appearanceTab
                    case 3:
                        featuresTab
                    case 4:
                        historyTab
                    default:
                        appSettingsAndAboutTab
                    }
                }
                .padding(Space.margin)
            }

            Divider()

            // Subtle Status Footer
            HStack {
                Text("Lamha Translate v1.2 • Native macOS Selection Translator")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Copyright © 2026 Binhanaa • MIT License")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, Space.margin)
            .padding(.vertical, Space.sm)
            .background(Color.primary.opacity(0.02))
        }
        .frame(width: 680, height: 580)
        .themed()
        .noInitialFocus()
        .environment(\.layoutDirection, settings.layoutDirection)
    }

    private func tabButton(index: Int, icon: String, title: String) -> some View {
        let isSelected = (settings.selectedSettingsTab == index)
        return Button(action: {
            withAnimation(Motion.quick) {
                settings.selectedSettingsTab = index
            }
        }) {
            HStack(spacing: Space.xs + 2) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 12.5, weight: isSelected ? .bold : .medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, Space.md - 2)
            .padding(.vertical, Space.xs + 3)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(isSelected ? Palette.accent : Color.clear)
            )
            .foregroundStyle(isSelected ? Palette.onAccent : .primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab 0: Languages
    private var languagesTab: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            settingsCard(title: s.sectionTranslationLanguages, icon: "character.book.closed.fill") {
                VStack(alignment: .leading, spacing: Space.md) {
                    symmetricalPickerRow(
                        title: s.defaultTargetLanguage,
                        subtitle: s.defaultTargetLanguageSub,
                        selection: $settings.targetLanguage,
                        options: AppSettings.supportedLanguages.map {
                            DropdownOption(value: $0.code, label: $0.localizedLabel(in: settings.effectiveAppLanguage))
                        }
                    )

                    Divider()

                    symmetricalPickerRow(
                        title: s.sourceLanguageLabel,
                        subtitle: s.sourceLanguageSub,
                        selection: $settings.sourceLanguage,
                        options: settings.sourceLanguagesList().map {
                            DropdownOption(value: $0.code, label: $0.localizedLabel(in: settings.effectiveAppLanguage))
                        }
                    )
                }
            }

            settingsCard(title: s.sectionSmartReverse, icon: "arrow.left.arrow.right.circle.fill") {
                VStack(alignment: .leading, spacing: Space.md) {
                    symmetricalToggleRow(
                        title: s.smartReverseToggle,
                        subtitle: s.smartReverseSub,
                        isOn: $settings.smartReverseTranslation
                    )

                    if settings.smartReverseTranslation {
                        Divider()
                        symmetricalPickerRow(
                            title: s.secondaryLanguageLabel,
                            subtitle: nil,
                            selection: $settings.secondaryLanguage,
                            options: AppSettings.supportedLanguages.map {
                                DropdownOption(value: $0.code, label: $0.localizedLabel(in: settings.effectiveAppLanguage))
                            }
                        )
                    }
                }
            }

            settingsCard(title: s.sectionDictionary, icon: "text.book.closed.fill") {
                symmetricalToggleRow(
                    title: s.dictionaryToggle,
                    subtitle: s.dictionarySub,
                    isOn: $settings.showDictionarySynonyms
                )
            }
        }
    }

    // MARK: - Tab 1: Mouse & Trackpad
    private var mouseAndTriggerTab: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            settingsCard(title: s.sectionTriggerMode, icon: "cursorarrow.click.2") {
                VStack(alignment: .leading, spacing: Space.sm) {
                    ForEach(TriggerMode.allCases) { mode in
                        radioRow(
                            isSelected: settings.triggerMode == mode,
                            title: mode.title(in: s),
                            subtitle: mode.subtitle(in: s)
                        ) {
                            settings.triggerMode = mode
                        }
                    }
                }
            }

            settingsCard(title: s.sectionBadgePlacement, icon: "location.circle.fill") {
                VStack(alignment: .leading, spacing: Space.md) {
                    symmetricalPickerRow(
                        title: s.badgePositionLabel,
                        subtitle: nil,
                        selection: $settings.badgePosition,
                        options: BadgePosition.allCases.map {
                            DropdownOption(value: $0, label: $0.title(in: s))
                        }
                    )

                    Divider()

                    symmetricalSliderRow(
                        title: s.autoDismissLabel,
                        valueText: String(format: "%.1f %@", settings.autoDismissSeconds, s.secondsUnit),
                        value: $settings.autoDismissSeconds,
                        range: 1.5...8.0,
                        step: 0.5
                    )
                }
            }

            settingsCard(title: s.sectionShortcuts, icon: "command.circle.fill") {
                VStack(alignment: .leading, spacing: Space.md) {
                    symmetricalPickerRow(
                        title: s.modifierKeyLabel,
                        subtitle: nil,
                        selection: $settings.modifierRequirement,
                        options: ModifierRequirement.allCases.map {
                            DropdownOption(value: $0, label: $0.title(in: s))
                        }
                    )

                    Divider()

                    symmetricalToggleRow(
                        title: s.doubleCopyToggle,
                        subtitle: s.doubleCopySub,
                        isOn: $settings.doubleCopyTranslate
                    )

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: Space.xxs) {
                            Text(s.globalHotkeyLabel)
                                .font(.system(size: 13, weight: .semibold))
                            Text(s.globalHotkeySub)
                                .font(.system(size: 11.5))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("⌥ Option + T")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .padding(.horizontal, Space.md)
                            .padding(.vertical, Space.xs + 2)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.xs, style: .continuous)
                                    .fill(Palette.accent.opacity(0.14))
                            )
                            .foregroundStyle(Palette.accentText)
                    }
                }
            }
        }
    }

    // MARK: - Tab 2: Appearance
    private var appearanceTab: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            settingsCard(title: s.sectionVisualTuning, icon: "slider.horizontal.below.rectangle") {
                VStack(alignment: .leading, spacing: Space.md) {
                    symmetricalPickerRow(
                        title: s.themeModeLabel,
                        subtitle: nil,
                        selection: $settings.themeMode,
                        options: ThemeMode.allCases.map {
                            DropdownOption(value: $0, label: $0.title(in: s))
                        }
                    )

                    Divider()

                    symmetricalSliderRow(
                        title: s.windowOpacityLabel,
                        valueText: "\(Int(settings.windowOpacity * 100))%",
                        value: $settings.windowOpacity,
                        range: 0.75...1.0,
                        step: 0.02
                    )

                    Divider()

                    symmetricalSliderRow(
                        title: s.fontSizeLabel,
                        valueText: "\(Int(settings.fontSize)) pt",
                        value: $settings.fontSize,
                        range: 12...24,
                        step: 1
                    )

                    Divider()

                    symmetricalSliderRow(
                        title: s.badgeSizeLabel,
                        valueText: "\(Int(settings.badgeSize)) px",
                        value: $settings.badgeSize,
                        range: 22...38,
                        step: 2
                    )
                }
            }

            settingsCard(title: s.sectionLivePreview, icon: "eye.circle.fill") {
                VStack(alignment: .leading, spacing: Space.sm) {
                    Text(s.previewPrompt)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    HStack(spacing: Space.md) {
                        TextField("", text: $testSampleText)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 13))

                        Button(action: {
                            let mouseLoc = NSEvent.mouseLocation
                            FloatingPanelController.shared.showTranslationPopup(
                                for: testSampleText,
                                at: mouseLoc
                            )
                        }) {
                            Label(s.previewButton, systemImage: "sparkles")
                                .font(.system(size: 12.5, weight: .semibold))
                                .padding(.horizontal, Space.md)
                                .padding(.vertical, Space.xs + 2)
                                .background(
                                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                        .fill(Palette.accent)
                                )
                                .foregroundStyle(Palette.onAccent)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Tab 3: Features
    private var featuresTab: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            settingsCard(title: s.sectionAdvanced, icon: "bolt.circle.fill") {
                VStack(alignment: .leading, spacing: Space.md) {
                    symmetricalToggleRow(
                        title: s.smartFallbackToggle,
                        subtitle: s.smartFallbackSub,
                        isOn: $settings.smartClipboardFallback
                    )

                    Divider()

                    symmetricalToggleRow(
                        title: s.autoCopyToggle,
                        subtitle: s.autoCopySub,
                        isOn: $settings.autoCopyTranslation
                    )
                }
            }
        }
    }

    // MARK: - Tab 4: History
    private var historyTab: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(spacing: Space.md) {
                HStack(spacing: Space.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField(s.searchHistoryPlaceholder, text: $searchQuery)
                        .textFieldStyle(.plain)
                }
                .padding(Space.sm)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(Surfaces.cardFill)
                )

                if !settings.history.isEmpty {
                    Button(role: .destructive, action: {
                        settings.clearHistory()
                    }) {
                        Label(s.clearHistoryBtn, systemImage: "trash")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(.bordered)
                }
            }

            let filtered = settings.history.filter { item in
                guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return true }
                return item.sourceText.localizedCaseInsensitiveContains(searchQuery) ||
                       item.translatedText.localizedCaseInsensitiveContains(searchQuery)
            }

            if filtered.isEmpty {
                VStack(spacing: Space.md) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text(s.emptyHistoryText)
                        .font(.system(size: 13.5, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                ForEach(filtered) { item in
                    VStack(alignment: .leading, spacing: Space.xs + 2) {
                        HStack {
                            Text("\(item.sourceLang.uppercased()) → \(item.targetLang.uppercased())")
                                .font(.system(size: 10.5, weight: .bold))
                                .padding(.horizontal, Space.sm)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Palette.accent.opacity(0.14)))
                                .foregroundStyle(Palette.accentText)

                            Spacer()

                            Button(action: {
                                SpeechService.shared.speak(item.translatedText, languageCode: item.targetLang)
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 11.5))
                            }
                            .buttonStyle(.borderless)
                            .help(s.speakTooltip)

                            Button(action: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(item.translatedText, forType: .string)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 11.5))
                            }
                            .buttonStyle(.borderless)
                            .help(s.copyBtn)
                        }

                        Text(item.translatedText)
                            .font(.system(size: 13.5, weight: .semibold))
                            .textSelection(.enabled)

                        Text(item.sourceText)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(Space.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                            .fill(Surfaces.cardFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                    .strokeBorder(Surfaces.hairline, lineWidth: 1)
                            )
                    )
                }
            }
        }
    }

    // MARK: - Tab 5: App Settings, One-Time Setup & Developer Info
    private var appSettingsAndAboutTab: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            // 1. App Interface Language (Moved here from Header & Languages tab)
            settingsCard(title: s.sectionAppLanguage, icon: "globe.badge.chevron.backward") {
                symmetricalPickerRow(
                    title: s.appInterfaceLanguage,
                    subtitle: s.appInterfaceLanguageSub,
                    selection: $settings.appLanguage,
                    options: settings.appLanguageOptions().map {
                        DropdownOption(value: $0.code, label: $0.localizedLabel(in: settings.effectiveAppLanguage))
                    }
                )
            }

            // 2. One-Time Accessibility Permission Setup
            settingsCard(title: s.sectionPermissions, icon: "hand.raised.circle.fill") {
                VStack(alignment: .leading, spacing: Space.md) {
                    HStack(spacing: Space.md) {
                        Image(systemName: monitor.isAccessibilityTrusted ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(monitor.isAccessibilityTrusted ? Palette.success : Palette.warning)

                        VStack(alignment: .leading, spacing: Space.xxs) {
                            Text(monitor.isAccessibilityTrusted ? s.permissionGrantedTitle : s.permissionMissingTitle)
                                .font(.system(size: 13, weight: .bold))
                            Text(s.permissionDesc)
                                .font(.system(size: 11.5))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if !monitor.isAccessibilityTrusted {
                            Button(s.grantPermissionBtn) {
                                monitor.openAccessibilitySettings()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }

                        Button(s.refreshStatusBtn) {
                            _ = monitor.checkAccessibilityPermission(prompt: false)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }

            // 3. Startup & Factory Reset
            settingsCard(title: s.launchAtLoginToggle, icon: "power.circle.fill") {
                VStack(alignment: .leading, spacing: Space.md) {
                    symmetricalToggleRow(
                        title: s.launchAtLoginToggle,
                        subtitle: s.launchAtLoginSub,
                        isOn: $settings.launchAtLogin
                    )

                    Divider()

                    HStack {
                        Text(s.resetDefaultsLabel)
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                        Button(role: .destructive, action: {
                            settings.resetToDefaults()
                        }) {
                            Text(s.resetDefaultsBtn)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }

            // 4. Developer Info & GitHub Profile Card
            settingsCard(title: s.sectionDeveloper, icon: "person.crop.circle.badge.checkmark") {
                HStack(spacing: Space.lg) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Palette.accent, Palette.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                        Text("B")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(Palette.onAccent)
                    }

                    VStack(alignment: .leading, spacing: Space.xs) {
                        HStack(spacing: Space.sm) {
                            Text(s.developerTitle)
                                .font(.system(size: 14, weight: .bold))
                            Text("@Binhanaa")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .padding(.horizontal, Space.sm)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Palette.accent.opacity(0.14)))
                                .foregroundStyle(Palette.accentText)
                        }

                        Text(s.developerBio)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: Space.sm)

                    VStack(alignment: .trailing, spacing: Space.xs + 2) {
                        Button(action: {
                            if let url = URL(string: "https://github.com/Binhanaa") {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: Space.xs + 2) {
                                GitHubIconView(size: 14)
                                Text(s.githubProfileBtn)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(Palette.onAccent)
                            .padding(.horizontal, Space.md)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                    .fill(Palette.accent)
                            )
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            if let url = URL(string: "https://github.com/Binhanaa/LamhaTranslate") {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: Space.xs + 2) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 11.5, weight: .semibold))
                                Text(s.githubRepoBtn)
                                    .font(.system(size: 11.5, weight: .medium))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, Space.md)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                    .fill(Color.primary.opacity(0.08))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Reusable Symmetrical Building Blocks
    private func settingsCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(spacing: Space.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Palette.accent)
                Text(title)
                    .font(.system(size: 13.5, weight: .bold))
            }

            VStack(alignment: .leading, spacing: Space.md) {
                content()
            }
            .padding(Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(Surfaces.cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                            .strokeBorder(Surfaces.hairline, lineWidth: 1)
                    )
            )
        }
    }

    private func symmetricalPickerRow<Value: Hashable>(
        title: String,
        subtitle: String?,
        selection: Binding<Value>,
        options: [DropdownOption<Value>]
    ) -> some View {
        HStack(alignment: .center, spacing: Space.lg) {
            VStack(alignment: .leading, spacing: Space.xxs) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .multilineTextAlignment(.leading)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: Space.md)
            LamhaDropdown(
                selection: selection,
                options: options,
                isRTL: settings.isUI_RTL,
                width: 235
            )
        }
    }

    private func symmetricalToggleRow(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(alignment: .center, spacing: Space.lg) {
            VStack(alignment: .leading, spacing: Space.xxs) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.system(size: 11.5))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: Space.md)
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
    }

    private func symmetricalSliderRow(
        title: String,
        valueText: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double
    ) -> some View {
        HStack(alignment: .center, spacing: Space.md) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .multilineTextAlignment(.leading)
            Spacer(minLength: Space.md)
            HStack(spacing: Space.sm) {
                Slider(value: value, in: range, step: step)
                    .frame(width: 170)
                Text(valueText)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.accentText)
                    .frame(width: 58, alignment: .trailing)
            }
        }
    }

    private func radioRow(
        isSelected: Bool,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: Space.md) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? Palette.accent : .secondary)

                VStack(alignment: .leading, spacing: Space.xxs) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(Space.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: Radius.row, style: .continuous)
                    .fill(isSelected ? Palette.accent.opacity(0.10) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
