import Foundation
import SwiftUI
import Combine
import ServiceManagement

public struct LanguageOption: Identifiable, Hashable, Codable {
    public let code: String
    public let arabicName: String
    public let nativeName: String
    public let flag: String
    public let isRTL: Bool

    public var id: String { code }

    public func localizedLabel(in appLang: String) -> String {
        if appLang.lowercased() == "ar" {
            return "\(flag) \(arabicName)"
        }
        return "\(flag) \(nativeName)"
    }

    public func shortLabel(in appLang: String) -> String {
        if appLang.lowercased() == "ar" {
            return "\(flag) \(arabicName)"
        }
        return "\(flag) \(nativeName)"
    }
}

public enum TriggerMode: String, CaseIterable, Identifiable, Codable {
    case showIconClick = "icon_click"
    case showIconHover = "icon_hover"
    case instantTranslate = "instant"

    public var id: String { rawValue }

    public func title(in s: AppStrings) -> String {
        switch self {
        case .showIconClick: return s.triggerClickTitle
        case .showIconHover: return s.triggerHoverTitle
        case .instantTranslate: return s.triggerInstantTitle
        }
    }

    public func subtitle(in s: AppStrings) -> String {
        switch self {
        case .showIconClick: return s.triggerClickSub
        case .showIconHover: return s.triggerHoverSub
        case .instantTranslate: return s.triggerInstantSub
        }
    }
}

public enum BadgePosition: String, CaseIterable, Identifiable, Codable {
    case topRight = "top_right"
    case bottomRight = "bottom_right"
    case topLeft = "top_left"
    case bottomCenter = "bottom_center"

    public var id: String { rawValue }

    public func title(in s: AppStrings) -> String {
        switch self {
        case .topRight: return s.posTopRight
        case .bottomRight: return s.posBottomRight
        case .topLeft: return s.posTopLeft
        case .bottomCenter: return s.posBottomCenter
        }
    }

    public var offset: CGPoint {
        switch self {
        case .topRight: return CGPoint(x: 16, y: 16)
        case .bottomRight: return CGPoint(x: 16, y: -36)
        case .topLeft: return CGPoint(x: -40, y: 16)
        case .bottomCenter: return CGPoint(x: -16, y: -36)
        }
    }
}

public enum ModifierRequirement: String, CaseIterable, Identifiable, Codable {
    case none = "none"
    case option = "option"
    case command = "command"
    case control = "control"

    public var id: String { rawValue }

    public func title(in s: AppStrings) -> String {
        switch self {
        case .none: return s.modNone
        case .option: return s.modOption
        case .command: return s.modCommand
        case .control: return s.modControl
        }
    }
}

public enum ThemeMode: String, CaseIterable, Identifiable, Codable {
    case system = "system"
    case darkGlass = "dark"
    case lightGlass = "light"

    public var id: String { rawValue }

    public func title(in s: AppStrings) -> String {
        switch self {
        case .system: return s.themeSystem
        case .darkGlass: return s.themeDark
        case .lightGlass: return s.themeLight
        }
    }
}

public struct TranslationHistoryItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public let sourceText: String
    public let translatedText: String
    public let sourceLang: String
    public let targetLang: String
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        sourceText: String,
        translatedText: String,
        sourceLang: String,
        targetLang: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLang = sourceLang
        self.targetLang = targetLang
        self.timestamp = timestamp
    }
}

@MainActor
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()

    public static let supportedLanguages: [LanguageOption] = [
        LanguageOption(code: "ar", arabicName: "العربية", nativeName: "العربية", flag: "🇸🇦", isRTL: true),
        LanguageOption(code: "en", arabicName: "الإنجليزية", nativeName: "English", flag: "🇺🇸", isRTL: false),
        LanguageOption(code: "fr", arabicName: "الفرنسية", nativeName: "Français", flag: "🇫🇷", isRTL: false),
        LanguageOption(code: "es", arabicName: "الإسبانية", nativeName: "Español", flag: "🇪🇸", isRTL: false),
        LanguageOption(code: "de", arabicName: "الألمانية", nativeName: "Deutsch", flag: "🇩🇪", isRTL: false),
        LanguageOption(code: "tr", arabicName: "التركية", nativeName: "Türkçe", flag: "🇹🇷", isRTL: false),
        LanguageOption(code: "ru", arabicName: "الروسية", nativeName: "Русский", flag: "🇷🇺", isRTL: false),
        LanguageOption(code: "zh-CN", arabicName: "الصينية", nativeName: "中文", flag: "🇨🇳", isRTL: false),
        LanguageOption(code: "ja", arabicName: "اليابانية", nativeName: "日本語", flag: "🇯🇵", isRTL: false),
        LanguageOption(code: "ko", arabicName: "الكورية", nativeName: "한국어", flag: "🇰🇷", isRTL: false),
        LanguageOption(code: "it", arabicName: "الإيطالية", nativeName: "Italiano", flag: "🇮🇹", isRTL: false),
        LanguageOption(code: "pt", arabicName: "البرتغالية", nativeName: "Português", flag: "🇵🇹", isRTL: false),
        LanguageOption(code: "nl", arabicName: "الهولندية", nativeName: "Nederlands", flag: "🇳🇱", isRTL: false),
        LanguageOption(code: "hi", arabicName: "الهندية", nativeName: "हिन्दी", flag: "🇮🇳", isRTL: false),
        LanguageOption(code: "ur", arabicName: "الأردية", nativeName: "اردو", flag: "🇵🇰", isRTL: true),
        LanguageOption(code: "fa", arabicName: "الفارسية", nativeName: "فارسی", flag: "🇮🇷", isRTL: true)
    ]

    /// Detects the user's macOS system language and maps it to one of the supported languages
    public nonisolated static func detectSystemLanguageCode() -> String {
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
        if preferred.hasPrefix("ar") { return "ar" }
        if preferred.hasPrefix("en") { return "en" }
        if preferred.hasPrefix("fr") { return "fr" }
        if preferred.hasPrefix("es") { return "es" }
        if preferred.hasPrefix("de") { return "de" }
        if preferred.hasPrefix("tr") { return "tr" }
        if preferred.hasPrefix("ru") { return "ru" }
        if preferred.hasPrefix("zh") { return "zh-CN" }
        if preferred.hasPrefix("ja") { return "ja" }
        if preferred.hasPrefix("ko") { return "ko" }
        if preferred.hasPrefix("it") { return "it" }
        if preferred.hasPrefix("pt") { return "pt" }
        if preferred.hasPrefix("nl") { return "nl" }
        if preferred.hasPrefix("hi") { return "hi" }
        if preferred.hasPrefix("ur") { return "ur" }
        if preferred.hasPrefix("fa") { return "fa" }
        return "en"
    }

    /// Resolved active language code (resolves `"system"` to the user's macOS system language)
    public var effectiveAppLanguage: String {
        if appLanguage.lowercased() == "system" {
            return Self.detectSystemLanguageCode()
        }
        return appLanguage
    }

    public var strings: AppStrings {
        L10n.strings(for: effectiveAppLanguage)
    }

    public var layoutDirection: LayoutDirection {
        L10n.layoutDirection(for: effectiveAppLanguage)
    }

    public var isUI_RTL: Bool {
        L10n.isRTL(effectiveAppLanguage)
    }

    @Published public var appLanguage: String {
        didSet { UserDefaults.standard.set(appLanguage, forKey: "lamha_appLanguage_v2") }
    }

    @Published public var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "lamha_isEnabled") }
    }

    @Published public var targetLanguage: String {
        didSet { UserDefaults.standard.set(targetLanguage, forKey: "lamha_targetLanguage") }
    }

    @Published public var sourceLanguage: String {
        didSet { UserDefaults.standard.set(sourceLanguage, forKey: "lamha_sourceLanguage") }
    }

    @Published public var smartReverseTranslation: Bool {
        didSet { UserDefaults.standard.set(smartReverseTranslation, forKey: "lamha_smartReverse") }
    }

    @Published public var secondaryLanguage: String {
        didSet { UserDefaults.standard.set(secondaryLanguage, forKey: "lamha_secondaryLanguage") }
    }

    @Published public var triggerMode: TriggerMode {
        didSet { UserDefaults.standard.set(triggerMode.rawValue, forKey: "lamha_triggerMode") }
    }

    @Published public var windowOpacity: Double {
        didSet { UserDefaults.standard.set(windowOpacity, forKey: "lamha_windowOpacity") }
    }

    @Published public var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: "lamha_fontSize") }
    }

    @Published public var badgeSize: Double {
        didSet { UserDefaults.standard.set(badgeSize, forKey: "lamha_badgeSize") }
    }

    @Published public var badgePosition: BadgePosition {
        didSet { UserDefaults.standard.set(badgePosition.rawValue, forKey: "lamha_badgePosition") }
    }

    @Published public var autoDismissSeconds: Double {
        didSet { UserDefaults.standard.set(autoDismissSeconds, forKey: "lamha_autoDismissSeconds") }
    }

    @Published public var modifierRequirement: ModifierRequirement {
        didSet { UserDefaults.standard.set(modifierRequirement.rawValue, forKey: "lamha_modifierRequirement") }
    }

    @Published public var smartClipboardFallback: Bool {
        didSet { UserDefaults.standard.set(smartClipboardFallback, forKey: "lamha_smartClipboardFallback") }
    }

    @Published public var doubleCopyTranslate: Bool {
        didSet { UserDefaults.standard.set(doubleCopyTranslate, forKey: "lamha_doubleCopyTranslate") }
    }

    @Published public var showDictionarySynonyms: Bool {
        didSet { UserDefaults.standard.set(showDictionarySynonyms, forKey: "lamha_showDictionarySynonyms") }
    }

    @Published public var autoCopyTranslation: Bool {
        didSet { UserDefaults.standard.set(autoCopyTranslation, forKey: "lamha_autoCopyTranslation") }
    }

    @Published public var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "lamha_launchAtLogin")
            updateLaunchAtLoginService(launchAtLogin)
        }
    }

    @Published public var themeMode: ThemeMode {
        didSet { UserDefaults.standard.set(themeMode.rawValue, forKey: "lamha_themeMode") }
    }

    @Published public var excludedBundleIDs: [String] {
        didSet { UserDefaults.standard.set(excludedBundleIDs, forKey: "lamha_excludedBundleIDs") }
    }

    @Published public var history: [TranslationHistoryItem] = []
    @Published public var selectedSettingsTab: Int = 0

    private init() {
        let defaults = UserDefaults.standard

        // Default to "system" so the app automatically matches the user's macOS system language
        self.appLanguage = defaults.string(forKey: "lamha_appLanguage_v2") ?? "system"
        self.isEnabled = defaults.object(forKey: "lamha_isEnabled") as? Bool ?? true
        self.targetLanguage = defaults.string(forKey: "lamha_targetLanguage") ?? "ar"
        self.sourceLanguage = defaults.string(forKey: "lamha_sourceLanguage") ?? "auto"
        self.smartReverseTranslation = defaults.object(forKey: "lamha_smartReverse") as? Bool ?? true
        self.secondaryLanguage = defaults.string(forKey: "lamha_secondaryLanguage") ?? "en"

        if let modeRaw = defaults.string(forKey: "lamha_triggerMode"),
           let mode = TriggerMode(rawValue: modeRaw) {
            self.triggerMode = mode
        } else {
            self.triggerMode = .showIconClick
        }

        let savedOpacity = defaults.double(forKey: "lamha_windowOpacity")
        self.windowOpacity = savedOpacity > 0.3 ? savedOpacity : 0.94

        let savedFontSize = defaults.double(forKey: "lamha_fontSize")
        self.fontSize = savedFontSize >= 11 ? savedFontSize : 15.0

        let savedBadgeSize = defaults.double(forKey: "lamha_badgeSize")
        self.badgeSize = savedBadgeSize >= 20 ? savedBadgeSize : 28.0

        if let posRaw = defaults.string(forKey: "lamha_badgePosition"),
           let pos = BadgePosition(rawValue: posRaw) {
            self.badgePosition = pos
        } else {
            self.badgePosition = .topRight
        }

        let savedDismiss = defaults.double(forKey: "lamha_autoDismissSeconds")
        self.autoDismissSeconds = savedDismiss >= 1.5 ? savedDismiss : 4.0

        if let modRaw = defaults.string(forKey: "lamha_modifierRequirement"),
           let mod = ModifierRequirement(rawValue: modRaw) {
            self.modifierRequirement = mod
        } else {
            self.modifierRequirement = .none
        }

        self.smartClipboardFallback = defaults.object(forKey: "lamha_smartClipboardFallback") as? Bool ?? true
        self.doubleCopyTranslate = defaults.object(forKey: "lamha_doubleCopyTranslate") as? Bool ?? true
        self.showDictionarySynonyms = defaults.object(forKey: "lamha_showDictionarySynonyms") as? Bool ?? true
        self.autoCopyTranslation = defaults.object(forKey: "lamha_autoCopyTranslation") as? Bool ?? false
        self.launchAtLogin = defaults.object(forKey: "lamha_launchAtLogin") as? Bool ?? (SMAppService.mainApp.status == .enabled)

        if let themeRaw = defaults.string(forKey: "lamha_themeMode"),
           let theme = ThemeMode(rawValue: themeRaw) {
            self.themeMode = theme
        } else {
            self.themeMode = .system
        }

        self.excludedBundleIDs = defaults.stringArray(forKey: "lamha_excludedBundleIDs") ?? []

        if let data = defaults.data(forKey: "lamha_history"),
           let decoded = try? JSONDecoder().decode([TranslationHistoryItem].self, from: data) {
            self.history = decoded
        }
    }

    public func appLanguageOptions() -> [LanguageOption] {
        let sysLabel = (effectiveAppLanguage.lowercased() == "ar")
            ? "تلقائي (حسب لغة النظام)"
            : "System Default"
        return [
            LanguageOption(
                code: "system",
                arabicName: sysLabel,
                nativeName: sysLabel,
                flag: "💻",
                isRTL: isUI_RTL
            )
        ] + Self.supportedLanguages
    }

    public func sourceLanguagesList() -> [LanguageOption] {
        [
            LanguageOption(
                code: "auto",
                arabicName: strings.autoDetectLanguage,
                nativeName: strings.autoDetectLanguage,
                flag: "✨",
                isRTL: false
            )
        ] + Self.supportedLanguages
    }

    public func languageOption(for code: String) -> LanguageOption {
        if code.lowercased() == "system" {
            let sysLabel = (effectiveAppLanguage.lowercased() == "ar")
                ? "تلقائي (حسب لغة النظام)"
                : "System Default"
            return LanguageOption(
                code: "system",
                arabicName: sysLabel,
                nativeName: sysLabel,
                flag: "💻",
                isRTL: isUI_RTL
            )
        }
        if code.lowercased() == "auto" {
            return LanguageOption(
                code: "auto",
                arabicName: strings.autoDetectLanguage,
                nativeName: strings.autoDetectLanguage,
                flag: "✨",
                isRTL: false
            )
        }
        if let found = Self.supportedLanguages.first(where: { $0.code.lowercased() == code.lowercased() }) {
            return found
        }
        if let prefixFound = Self.supportedLanguages.first(where: { code.lowercased().hasPrefix($0.code.lowercased()) }) {
            return prefixFound
        }
        return LanguageOption(code: code, arabicName: code.uppercased(), nativeName: code.uppercased(), flag: "🌐", isRTL: false)
    }

    public func addHistoryItem(sourceText: String, translatedText: String, sourceLang: String, targetLang: String) {
        let trimmedSource = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTarget = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSource.isEmpty, !trimmedTarget.isEmpty else { return }

        history.removeAll { $0.sourceText == trimmedSource && $0.targetLang == targetLang }
        let newItem = TranslationHistoryItem(
            sourceText: trimmedSource,
            translatedText: trimmedTarget,
            sourceLang: sourceLang,
            targetLang: targetLang
        )
        history.insert(newItem, at: 0)
        if history.count > 50 {
            history = Array(history.prefix(50))
        }
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "lamha_history")
        }
    }

    public func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: "lamha_history")
    }

    public func resetToDefaults() {
        appLanguage = "system"
        isEnabled = true
        targetLanguage = "ar"
        sourceLanguage = "auto"
        smartReverseTranslation = true
        secondaryLanguage = "en"
        triggerMode = .showIconClick
        windowOpacity = 0.94
        fontSize = 15.0
        badgeSize = 28.0
        badgePosition = .topRight
        autoDismissSeconds = 4.0
        modifierRequirement = .none
        smartClipboardFallback = true
        doubleCopyTranslate = true
        showDictionarySynonyms = true
        autoCopyTranslation = false
        themeMode = .system
    }

    private func updateLaunchAtLoginService(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            // Ignore when running outside /Applications bundle
        }
    }
}
