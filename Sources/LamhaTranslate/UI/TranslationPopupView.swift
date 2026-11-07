import SwiftUI
import AppKit

@MainActor
private final class LanguageMenuTarget: NSObject {
    static let shared = LanguageMenuTarget()
    var onSelectLanguage: ((String) -> Void)?

    @objc func selectLanguageItem(_ sender: NSMenuItem) {
        guard let code = sender.representedObject as? String else { return }
        onSelectLanguage?(code)
    }
}

public struct TranslationPopupView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var speechService = SpeechService.shared

    let sourceText: String
    let onClose: () -> Void
    let onOpenSettings: () -> Void
    let onResizeNeeded: (CGSize) -> Void

    @State private var result: TranslationResult?
    @State private var isLoading: Bool
    @State private var errorMessage: String?
    @State private var copiedFeedback: Bool = false
    @State private var customTargetLang: String? = nil

    public init(
        sourceText: String,
        onClose: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void,
        onResizeNeeded: @escaping (CGSize) -> Void
    ) {
        self.sourceText = sourceText
        self.onClose = onClose
        self.onOpenSettings = onOpenSettings
        self.onResizeNeeded = onResizeNeeded

        let preCached = TranslationService.shared.cachedResult(for: sourceText)
        self._result = State(initialValue: preCached)
        self._isLoading = State(initialValue: preCached == nil)
    }

    private var s: AppStrings { settings.strings }

    private var activeTargetLangCode: String {
        result?.targetLanguage ?? customTargetLang ?? settings.targetLanguage
    }

    private var isTargetRTL: Bool {
        let lang = settings.languageOption(for: activeTargetLangCode)
        if lang.isRTL { return true }
        if let translated = result?.translatedText {
            return TranslationService.containsPredominantlyArabic(translated)
        }
        return false
    }

    private var effectiveScheme: ColorScheme {
        switch settings.themeMode {
        case .system: return Surfaces.currentSystemColorScheme
        case .darkGlass: return .dark
        case .lightGlass: return .light
        }
    }

    private var isDarkSurface: Bool {
        effectiveScheme == .dark
    }

    private var surfaceBackgroundColor: Color {
        let base = isDarkSurface ? Surfaces.popupDarkBg : Surfaces.popupLightBg
        let clampedOpacity = min(max(settings.windowOpacity, 0.88), 0.97)
        return base.opacity(clampedOpacity)
    }

    private var primaryTextColor: Color {
        isDarkSurface ? Color.white : Color(hex: 0x0F172A)
    }

    private var secondaryTextColor: Color {
        isDarkSurface ? Color.white.opacity(0.75) : Color(hex: 0x475569)
    }

    private var controlBgColor: Color {
        isDarkSurface ? Color.white.opacity(0.12) : Color.black.opacity(0.075)
    }

    private var borderStrokeColor: Color {
        isDarkSurface ? Color.white.opacity(0.22) : Color.black.opacity(0.14)
    }

    public var body: some View {
        glassCardView
            .environment(\.colorScheme, effectiveScheme)
            .themed()
            .noInitialFocus()
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newSize in
                onResizeNeeded(newSize)
            }
            .task(id: "\(sourceText)|\(customTargetLang ?? settings.targetLanguage)") {
                await performTranslation()
            }
    }

    private var glassCardView: some View {
        let textCount = result?.translatedText.count ?? sourceText.count
        let cardWidth: CGFloat = textCount > 120 ? 410 : 350

        return VStack(alignment: .leading, spacing: 0) {
            // Top Bar: [Close] [Settings] [Audio] [Copy] ... [Circular Flag Button]
            HStack(spacing: Space.xs + 2) {
                // 1. Close
                circleIconButton(icon: "xmark", tint: secondaryTextColor, tooltip: "Esc", action: onClose)

                // 2. Settings
                circleIconButton(
                    icon: "gearshape",
                    tint: secondaryTextColor,
                    tooltip: s.openSettingsBtn,
                    action: onOpenSettings
                )

                // 3. Audio / Speak
                circleIconButton(
                    icon: speechService.isSpeaking ? "stop.fill" : "speaker.wave.2.fill",
                    tint: speechService.isSpeaking ? Palette.accent : secondaryTextColor,
                    tooltip: s.speakTooltip
                ) {
                    if let result {
                        speechService.speak(result.translatedText, languageCode: result.targetLanguage)
                    } else {
                        speechService.speak(sourceText, languageCode: settings.sourceLanguage)
                    }
                }

                // 4. Copy Icon
                if let result {
                    circleIconButton(
                        icon: copiedFeedback ? "checkmark" : "doc.on.doc",
                        tint: copiedFeedback ? Palette.success : secondaryTextColor,
                        tooltip: copiedFeedback ? s.copiedBtn : s.copyBtn
                    ) {
                        copyTranslation(result.translatedText)
                    }
                }

                Spacer(minLength: Space.sm)

                // 5. Opposite Circular Flag Button (Exact same 24x24 circle size)
                languageFlagCircleButton
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.sm + 2)

            Divider()
                .overlay(borderStrokeColor.opacity(0.65))

            // Main Body Content (Zero Footer below)
            if isLoading {
                HStack(spacing: Space.sm) {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                    Text(s.translatingText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(secondaryTextColor)
                    Spacer()
                }
                .padding(.vertical, Space.xl)
            } else if let errorMessage {
                VStack(spacing: Space.sm) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 18))
                        .foregroundStyle(Palette.warning)
                    Text(errorMessage)
                        .font(.system(size: 12.5))
                        .foregroundStyle(secondaryTextColor)
                        .multilineTextAlignment(.center)
                    Button(s.retryBtn) {
                        Task { await performTranslation() }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .frame(maxWidth: .infinity)
                .padding(Space.lg)
            } else if let result {
                if result.translatedText.count > 700 {
                    ScrollView(.vertical, showsIndicators: true) {
                        translationBodyContent(result: result)
                    }
                    .frame(height: 240)
                } else {
                    translationBodyContent(result: result)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(width: cardWidth)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(surfaceBackgroundColor)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            borderStrokeColor,
                            Palette.accent.opacity(0.32)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.1
                )
        )
        .shadow(color: Color.black.opacity(isDarkSurface ? 0.42 : 0.20), radius: 14, x: 0, y: 6)
    }

    @ViewBuilder
    private func translationBodyContent(result: TranslationResult) -> some View {
        let formattedText: String = {
            guard isTargetRTL else { return result.translatedText }
            // Prefix each paragraph with RLM (\u{200F}) so mixed Arabic/English sentences always start strictly Right-to-Left
            return result.translatedText
                .components(separatedBy: "\n")
                .map { "\u{200F}" + $0 }
                .joined(separator: "\n")
        }()

        VStack(alignment: .leading, spacing: Space.md) {
            Text(formattedText)
                .font(.system(size: CGFloat(settings.fontSize), weight: .medium))
                .foregroundStyle(primaryTextColor)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if settings.showDictionarySynonyms && !result.dictionaryEntries.isEmpty {
                Divider()
                    .overlay(borderStrokeColor.opacity(0.5))
                VStack(alignment: .leading, spacing: Space.xs + 2) {
                    ForEach(result.dictionaryEntries.prefix(3)) { entry in
                        HStack(alignment: .top, spacing: Space.sm) {
                            partOfSpeechBadge(entry.partOfSpeech)
                            Text(entry.terms.joined(separator: isTargetRTL ? " ، " : ", "))
                                .font(.system(size: 12))
                                .foregroundStyle(secondaryTextColor)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .environment(\.layoutDirection, isTargetRTL ? .rightToLeft : .leftToRight)
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md + 2)
    }

    private func partOfSpeechBadge(_ pos: String) -> some View {
        Text(pos)
            .font(.system(size: 10.5, weight: .semibold))
            .foregroundStyle(Palette.accent)
            .padding(.horizontal, Space.sm)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Palette.accent.opacity(0.15))
            )
    }

    /// Circular 24x24 button displaying ONLY the target language flag, matching the opposite 24x24 control buttons
    private var languageFlagCircleButton: some View {
        let srcOption = settings.languageOption(for: result?.detectedSourceLanguage ?? settings.sourceLanguage)
        let tgtOption = settings.languageOption(for: activeTargetLangCode)

        return Button(action: {
            presentTargetLanguageMenu()
        }) {
            Text(tgtOption.flag)
                .font(.system(size: 13))
                .frame(width: 24, height: 24)
                .background(Circle().fill(controlBgColor))
        }
        .buttonStyle(.plain)
        .help("\(srcOption.shortLabel(in: settings.effectiveAppLanguage)) → \(tgtOption.shortLabel(in: settings.effectiveAppLanguage))")
    }

    private func presentTargetLanguageMenu() {
        let menu = NSMenu(title: s.translateToHeader)
        menu.userInterfaceLayoutDirection = settings.isUI_RTL ? .rightToLeft : .leftToRight
        let handler = LanguageMenuTarget.shared
        handler.onSelectLanguage = { selectedCode in
            self.customTargetLang = selectedCode
            self.settings.targetLanguage = selectedCode
        }

        for lang in AppSettings.supportedLanguages {
            let item = NSMenuItem(
                title: lang.localizedLabel(in: settings.effectiveAppLanguage),
                action: #selector(LanguageMenuTarget.selectLanguageItem(_:)),
                keyEquivalent: ""
            )
            item.target = handler
            item.representedObject = lang.code
            item.state = (lang.code == activeTargetLangCode) ? .on : .off
            menu.addItem(item)
        }

        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

    private func circleIconButton(
        icon: String,
        tint: Color,
        tooltip: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 24, height: 24)
                .background(Circle().fill(controlBgColor))
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }

    private func performTranslation() async {
        if let preCached = TranslationService.shared.cachedResult(
            for: sourceText,
            targetLang: customTargetLang
        ) {
            self.result = preCached
            self.isLoading = false
            self.errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let translationResult = try await TranslationService.shared.translate(
                text: sourceText,
                targetLang: customTargetLang
            )
            self.result = translationResult
            self.isLoading = false

            if settings.autoCopyTranslation {
                copyTranslation(translationResult.translatedText)
            }
        } catch {
            self.errorMessage = s.networkErrorText
            self.isLoading = false
        }
    }

    private func copyTranslation(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        withAnimation(Motion.quick) {
            copiedFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(Motion.quick) {
                copiedFeedback = false
            }
        }
    }
}
