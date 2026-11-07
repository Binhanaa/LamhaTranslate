import Foundation
import SwiftUI

public struct AppStrings {
    public let appName: String
    public let appTagline: String
    public let enabled: String
    public let disabled: String

    // Short Single-Word Tabs
    public let tabLanguages: String
    public let tabMouse: String
    public let tabAppearance: String
    public let tabFeatures: String
    public let tabHistory: String

    // Languages Tab
    public let sectionAppLanguage: String
    public let appInterfaceLanguage: String
    public let appInterfaceLanguageSub: String
    public let sectionTranslationLanguages: String
    public let defaultTargetLanguage: String
    public let defaultTargetLanguageSub: String
    public let sourceLanguageLabel: String
    public let sourceLanguageSub: String
    public let autoDetectLanguage: String
    public let sectionSmartReverse: String
    public let smartReverseToggle: String
    public let smartReverseSub: String
    public let secondaryLanguageLabel: String
    public let sectionDictionary: String
    public let dictionaryToggle: String
    public let dictionarySub: String

    // Mouse Tab
    public let sectionTriggerMode: String
    public let triggerClickTitle: String
    public let triggerClickSub: String
    public let triggerHoverTitle: String
    public let triggerHoverSub: String
    public let triggerInstantTitle: String
    public let triggerInstantSub: String
    public let sectionBadgePlacement: String
    public let badgePositionLabel: String
    public let posTopRight: String
    public let posBottomRight: String
    public let posTopLeft: String
    public let posBottomCenter: String
    public let autoDismissLabel: String
    public let secondsUnit: String
    public let sectionShortcuts: String
    public let modifierKeyLabel: String
    public let modNone: String
    public let modOption: String
    public let modCommand: String
    public let modControl: String
    public let doubleCopyToggle: String
    public let doubleCopySub: String
    public let globalHotkeyLabel: String
    public let globalHotkeySub: String

    // Appearance Tab
    public let sectionDisplayStyle: String
    public let styleGlassTitle: String
    public let styleGlassSub: String
    public let styleCompactTitle: String
    public let styleCompactSub: String
    public let sectionVisualTuning: String
    public let windowOpacityLabel: String
    public let fontSizeLabel: String
    public let badgeSizeLabel: String
    public let themeModeLabel: String
    public let themeSystem: String
    public let themeDark: String
    public let themeLight: String
    public let sectionLivePreview: String
    public let previewPrompt: String
    public let previewButton: String

    // Features & Permissions Tab
    public let sectionPermissions: String
    public let permissionGrantedTitle: String
    public let permissionMissingTitle: String
    public let permissionDesc: String
    public let grantPermissionBtn: String
    public let refreshStatusBtn: String
    public let sectionAdvanced: String
    public let smartFallbackToggle: String
    public let smartFallbackSub: String
    public let autoCopyToggle: String
    public let autoCopySub: String
    public let launchAtLoginToggle: String
    public let launchAtLoginSub: String
    public let resetDefaultsLabel: String
    public let resetDefaultsBtn: String

    // History Tab
    public let searchHistoryPlaceholder: String
    public let clearHistoryBtn: String
    public let emptyHistoryText: String

    // Popup & Menu Bar
    public let translatingText: String
    public let networkErrorText: String
    public let retryBtn: String
    public let copyBtn: String
    public let copiedBtn: String
    public let replaceBtn: String
    public let replacedBtn: String
    public let speakTooltip: String
    public let showOriginalBtn: String
    public let hideOriginalBtn: String
    public let originalTextHeader: String
    public let translateToHeader: String
    public let quickTranslateHeader: String
    public let quickTranslatePlaceholder: String
    public let openSettingsBtn: String
    public let quitBtn: String

    // Settings Tab & Developer Info (Localized across languages)
    @MainActor public var tabSettings: String {
        switch AppSettings.shared.effectiveAppLanguage.lowercased() {
        case "ar": return "الإعدادات"
        case "fr": return "Réglages"
        case "es": return "Ajustes"
        case "de": return "Optionen"
        case "tr": return "Ayarlar"
        case "ru": return "Настройки"
        case "zh-cn", "zh": return "设置"
        case "ja": return "設定"
        case "ko": return "설정"
        case "it": return "Impostazioni"
        case "pt": return "Ajustes"
        case "nl": return "Instellingen"
        case "hi": return "सेटिंग्स"
        case "ur": return "ترتیبات"
        case "fa": return "تنظیمات"
        default: return "Settings"
        }
    }

    @MainActor public var sectionDeveloper: String {
        switch AppSettings.shared.effectiveAppLanguage.lowercased() {
        case "ar": return "عن المبرمج والتطبيق"
        case "ur": return "ڈویلپر اور ایپ کے بارے میں"
        case "fa": return "درباره توسعه‌دهنده و برنامه"
        default: return "Developer & About"
        }
    }

    @MainActor public var developerTitle: String {
        switch AppSettings.shared.effectiveAppLanguage.lowercased() {
        case "ar": return "تطوير وبرمجة: Binhanaa"
        case "ur": return "ڈویلپر: Binhanaa"
        case "fa": return "توسعه‌دهنده: Binhanaa"
        default: return "Developed by Binhanaa"
        }
    }

    @MainActor public var developerBio: String {
        switch AppSettings.shared.effectiveAppLanguage.lowercased() {
        case "ar": return "تطوير تطبيقات وأدوات macOS الاحترافية فائقة السرعة والخفيفة على النظام"
        case "ur": return "اعلیٰ کارکردگی والی macOS ایپلیکیشنز اور ٹولز کی تیاری"
        case "fa": return "توسعه برنامه‌ها و ابزارهای حرفه‌ای و سریع macOS"
        default: return "Creator of high-performance, lightweight native macOS utilities & developer tools"
        }
    }

    @MainActor public var githubProfileBtn: String {
        switch AppSettings.shared.effectiveAppLanguage.lowercased() {
        case "ar": return "حساب المبرمج على GitHub"
        default: return "GitHub Profile (@Binhanaa)"
        }
    }

    @MainActor public var githubRepoBtn: String {
        switch AppSettings.shared.effectiveAppLanguage.lowercased() {
        case "ar": return "مستودع المشروع"
        default: return "Project Repository"
        }
    }
}

public enum L10n {
    public static func isRTL(_ code: String) -> Bool {
        let lower = code.lowercased()
        return lower == "ar" || lower == "ur" || lower == "fa" || lower == "he"
    }

    public static func layoutDirection(for code: String) -> LayoutDirection {
        isRTL(code) ? .rightToLeft : .leftToRight
    }

    public static func strings(for code: String) -> AppStrings {
        switch code.lowercased() {
        case "ar": return arabic
        case "en": return english
        case "fr": return french
        case "es": return spanish
        case "de": return german
        case "tr": return turkish
        case "ru": return russian
        case "zh-cn", "zh": return chinese
        case "ja": return japanese
        case "ko": return korean
        case "it": return italian
        case "pt": return portuguese
        case "nl": return dutch
        case "hi": return hindi
        case "ur": return urdu
        case "fa": return persian
        default: return english
        }
    }

    // MARK: - 1. Arabic (العربية)
    public static let arabic = AppStrings(
        appName: "لمحة — المترجم الفوري",
        appTagline: "ترجمة فورية خفيفة لأي نص تحدده بالماوس أو التراك باد في أي مكان",
        enabled: "مفعّل",
        disabled: "متوقف",
        tabLanguages: "اللغات",
        tabMouse: "الماوس",
        tabAppearance: "المظهر",
        tabFeatures: "الخصائص",
        tabHistory: "السجل",
        sectionAppLanguage: "لغة واجهة التطبيق",
        appInterfaceLanguage: "لغة عرض القوائم والإعدادات",
        appInterfaceLanguageSub: "تغيير لغة واجهة التطبيق بالكامل مع ضبط اتجاه القراءة تلقائياً (RTL / LTR)",
        sectionTranslationLanguages: "لغات الترجمة",
        defaultTargetLanguage: "اللغة التي أريد الترجمة إليها دائماً",
        defaultTargetLanguageSub: "يتم ترجمة أي نص تقوم بتحديده إلى هذه اللغة بشكل افتراضي",
        sourceLanguageLabel: "لغة النص المصدر",
        sourceLanguageSub: "يُنصح بتركها على الكشف التلقائي ليتعرف التطبيق على أي لغة فوراً",
        autoDetectLanguage: "كشف تلقائي للغة",
        sectionSmartReverse: "الترجمة العكسية الذكية",
        smartReverseToggle: "تفعيل الترجمة العكسية التلقائية",
        smartReverseSub: "عند تحديد نص مكتوب بلغتك الأساسية، يترجمه تلقائياً إلى اللغة البديلة",
        secondaryLanguageLabel: "اللغة البديلة للترجمة العكسية",
        sectionDictionary: "القاموس والمترادفات",
        dictionaryToggle: "عرض المعاني الإضافية وتصنيف الكلمات (اسم، فعل، صفة)",
        dictionarySub: "عند تحديد كلمة مفردة، يعرض معانيها المتعددة أسفل الترجمة الرئيسية",
        sectionTriggerMode: "طريقة التفعيل بالماوس والتراك باد",
        triggerClickTitle: "إظهار علامة صغيرة (النقر للترجمة)",
        triggerClickSub: "تظهر أيقونة أنيقة بجانب المؤشر عند تحديد نص، وتترجم عند النقر عليها",
        triggerHoverTitle: "إظهار علامة صغيرة (تمرير المؤشر للترجمة)",
        triggerHoverSub: "تظهر الأيقونة عند التحديد، وبمجرد تقريب المؤشر منها تفتح الترجمة بدون نقر",
        triggerInstantTitle: "ترجمة فورية بمجرد تحديد النص",
        triggerInstantSub: "تظهر الترجمة مباشرة فور انتهاء تحديد النص بالماوس أو التراك باد",
        sectionBadgePlacement: "موضع العلامة والاختفاء التلقائي",
        badgePositionLabel: "موضع ظهور العلامة بالنسبة للمؤشر",
        posTopRight: "أعلى اليمين",
        posBottomRight: "أسفل اليمين",
        posTopLeft: "أعلى اليسار",
        posBottomCenter: "أسفل المنتصف",
        autoDismissLabel: "إخفاء العلامة تلقائياً بعد",
        secondsUnit: "ثانية",
        sectionShortcuts: "الاختصارات وشروط التفعيل",
        modifierKeyLabel: "زر التحكم المطلوب أثناء التحديد",
        modNone: "بدون زر إضافي (يعمل دائماً)",
        modOption: "مع زر Option (⌥)",
        modCommand: "مع زر Command (⌘)",
        modControl: "مع زر Control (⌃)",
        doubleCopyToggle: "الترجمة عند الضغط على ⌘C مرتين متتاليتين",
        doubleCopySub: "حدد أي نص واضغط ⌘C مرتين لفتح نافذة الترجمة فوراً",
        globalHotkeyLabel: "اختصار لوحة المفاتيح العام",
        globalHotkeySub: "اضغط هذا الاختصار في أي وقت لترجمة النص المحدد حالياً",
        sectionDisplayStyle: "نمط نافذة الترجمة",
        styleGlassTitle: "نافذة زجاجية شفافة احترافية",
        styleGlassSub: "تعرض الترجمة كاملة مع النطق الصوتي، النسخ، القاموس، واستبدال النص",
        styleCompactTitle: "ترجمة في نفس الموضع (شريط مدمج)",
        styleCompactSub: "شريط زجاجي مصغر يظهر في موضع النص مباشرة بأبسط شكل ممكن",
        sectionVisualTuning: "الشفافية والخط والحجم",
        windowOpacityLabel: "درجة شفافية النافذة",
        fontSizeLabel: "حجم خط الترجمة",
        badgeSizeLabel: "حجم علامة الترجمة العائمة",
        themeModeLabel: "مظهر النافذة (داكن / فاتح)",
        themeSystem: "تلقائي (حسب مظهر النظام)",
        themeDark: "الوضع الداكن دائماً",
        themeLight: "الوضع الفاتح دائماً",
        sectionLivePreview: "تجربة ومعاينة حية",
        previewPrompt: "جرّب تحديد النص أو اضغط زر المعاينة لرؤية النافذة الشفافة:",
        previewButton: "معاينة النافذة الآن",
        sectionPermissions: "صلاحية تسهيلات الاستخدام (Accessibility)",
        permissionGrantedTitle: "الصلاحية مفعّلة — يعمل الالتقاط التلقائي بالماوس والتراك باد في كل مكان",
        permissionMissingTitle: "تفعيل صلاحية القراءة التلقائية للنصوص المحددة بالماوس",
        permissionDesc: "تُستخدم لقراءة النص المحدد بالماوس وإظهار علامة الترجمة بجانبه. كما يعمل اختصار (⌥+T) والنسخ المزدوج (⌘C مرتين) دائماً.",
        grantPermissionBtn: "فتح إعدادات الصلاحية",
        refreshStatusBtn: "تحديث الحالة",
        sectionAdvanced: "خصائص متقدمة",
        smartFallbackToggle: "الالتقاط الذكي المتقدم للمتصفحات وملفات PDF",
        smartFallbackSub: "يضمن قراءة التحديد في كافة المتصفحات مع الحفاظ التام على الحافظة",
        autoCopyToggle: "نسخ الترجمة تلقائياً إلى الحافظة",
        autoCopySub: "ينسخ النص المترجم تلقائياً فور ظهور الترجمة",
        launchAtLoginToggle: "التشغيل التلقائي عند بدء تشغيل الماك",
        launchAtLoginSub: "يبقى التطبيق جاهزاً في شريط القوائم العلوي عند تشغيل الجهاز",
        resetDefaultsLabel: "إعادة ضبط كافة الإعدادات إلى الوضع الافتراضي",
        resetDefaultsBtn: "استعادة الافتراضي",
        searchHistoryPlaceholder: "ابحث في سجل الترجمات...",
        clearHistoryBtn: "مسح السجل",
        emptyHistoryText: "لا توجد ترجمات محفوظة في السجل بعد",
        translatingText: "جاري الترجمة...",
        networkErrorText: "تعذر الاتصال بخدمة الترجمة. تأكد من اتصالك بالإنترنت.",
        retryBtn: "إعادة المحاولة",
        copyBtn: "نسخ",
        copiedBtn: "تم النسخ",
        replaceBtn: "استبدال بالموضع",
        replacedBtn: "تم الاستبدال",
        speakTooltip: "نطق صوتي",
        showOriginalBtn: "النص الأصلي",
        hideOriginalBtn: "إخفاء الأصل",
        originalTextHeader: "النص الأصلي:",
        translateToHeader: "الترجمة إلى:",
        quickTranslateHeader: "ترجمة فورية سريعة:",
        quickTranslatePlaceholder: "اكتب أو الصق نصاً للترجمة...",
        openSettingsBtn: "الإعدادات...",
        quitBtn: "إنهاء"
    )

    // MARK: - 2. English
    public static let english = AppStrings(
        appName: "Lamha — Instant Translator",
        appTagline: "Instant selection translator for mouse & trackpad",
        enabled: "Active",
        disabled: "Paused",
        tabLanguages: "Languages",
        tabMouse: "Mouse",
        tabAppearance: "Appearance",
        tabFeatures: "Features",
        tabHistory: "History",
        sectionAppLanguage: "App Interface Language",
        appInterfaceLanguage: "Display language for menus & settings",
        appInterfaceLanguageSub: "Switch the entire application interface language with automatic RTL/LTR layout",
        sectionTranslationLanguages: "Translation Languages",
        defaultTargetLanguage: "Default Target Language",
        defaultTargetLanguageSub: "Any text you select will be translated into this language by default",
        sourceLanguageLabel: "Source Text Language",
        sourceLanguageSub: "Recommended to leave on Auto-Detect so any language is recognized instantly",
        autoDetectLanguage: "Auto-Detect",
        sectionSmartReverse: "Smart Reverse Translation",
        smartReverseToggle: "Automatically reverse when selecting text in target language",
        smartReverseSub: "If selected text is already in your default target language, translate it to your secondary language",
        secondaryLanguageLabel: "Secondary Target Language",
        sectionDictionary: "Dictionary & Synonyms",
        dictionaryToggle: "Show dictionary definitions and parts of speech (noun, verb, adjective)",
        dictionarySub: "Displays multiple meanings and synonyms below single-word translations",
        sectionTriggerMode: "Mouse & Trackpad Trigger Behavior",
        triggerClickTitle: "Show mini floating icon (Click to translate)",
        triggerClickSub: "Displays a subtle badge near the cursor on selection; click it to open translation",
        triggerHoverTitle: "Show mini floating icon (Hover to translate)",
        triggerHoverSub: "Displays a subtle badge on selection; hover over it to translate without clicking",
        triggerInstantTitle: "Instant translation upon selection",
        triggerInstantSub: "Opens the translation overlay immediately as soon as you finish selecting text",
        sectionBadgePlacement: "Badge Position & Auto-Dismiss",
        badgePositionLabel: "Badge position relative to cursor",
        posTopRight: "Top Right",
        posBottomRight: "Bottom Right",
        posTopLeft: "Top Left",
        posBottomCenter: "Bottom Center",
        autoDismissLabel: "Auto-hide floating badge after",
        secondsUnit: "sec",
        sectionShortcuts: "Shortcuts & Activation Rules",
        modifierKeyLabel: "Required modifier key while selecting",
        modNone: "None (Always active on selection)",
        modOption: "Hold Option (⌥)",
        modCommand: "Hold Command (⌘)",
        modControl: "Hold Control (⌃)",
        doubleCopyToggle: "Translate on Double Copy (⌘C twice)",
        doubleCopySub: "Select any text and press ⌘C twice quickly to pop up translation",
        globalHotkeyLabel: "Global Keyboard Shortcut",
        globalHotkeySub: "Press anytime to translate currently selected text anywhere on macOS",
        sectionDisplayStyle: "Translation Overlay Style",
        styleGlassTitle: "Translucent Glass Card",
        styleGlassSub: "Full glass popover with audio pronunciation, copy, dictionary, and in-place replace",
        styleCompactTitle: "In-Place Compact Pill",
        styleCompactSub: "Ultra-minimal translucent bar right over the selection spot",
        sectionVisualTuning: "Transparency, Typography & Size",
        windowOpacityLabel: "Glass window opacity",
        fontSizeLabel: "Translation font size",
        badgeSizeLabel: "Floating trigger badge size",
        themeModeLabel: "Popup Window Appearance",
        themeSystem: "System (Auto Dark / Light)",
        themeDark: "Always Dark Mode",
        themeLight: "Always Light (White) Mode",
        sectionLivePreview: "Live Interactive Preview",
        previewPrompt: "Select the sample text or click Preview to test the floating glass popup:",
        previewButton: "Preview Popup",
        sectionPermissions: "Accessibility Permission",
        permissionGrantedTitle: "Permission Granted — Mouse & trackpad selection works system-wide",
        permissionMissingTitle: "Enable Accessibility to read mouse text selections automatically",
        permissionDesc: "Used only to read selected text and display the translate badge next to your cursor. Double ⌘C and ⌥+T work anytime.",
        grantPermissionBtn: "Open System Settings",
        refreshStatusBtn: "Refresh",
        sectionAdvanced: "Advanced Capabilities",
        smartFallbackToggle: "Smart Selection Capture for Browsers & PDFs",
        smartFallbackSub: "Ensures selection detection across all browsers while preserving your clipboard",
        autoCopyToggle: "Automatically copy translation to clipboard",
        autoCopySub: "Copies the translated text to your clipboard as soon as it appears",
        launchAtLoginToggle: "Launch Lamha automatically at login",
        launchAtLoginSub: "Keep Lamha ready in your macOS menu bar when you sign in",
        resetDefaultsLabel: "Restore all settings to factory defaults",
        resetDefaultsBtn: "Reset Defaults",
        searchHistoryPlaceholder: "Search translation history...",
        clearHistoryBtn: "Clear History",
        emptyHistoryText: "No translations in history yet",
        translatingText: "Translating...",
        networkErrorText: "Could not reach translation service. Check your connection.",
        retryBtn: "Retry",
        copyBtn: "Copy",
        copiedBtn: "Copied",
        replaceBtn: "Replace",
        replacedBtn: "Replaced",
        speakTooltip: "Listen",
        showOriginalBtn: "Original",
        hideOriginalBtn: "Hide Original",
        originalTextHeader: "Original Text:",
        translateToHeader: "Translate to:",
        quickTranslateHeader: "Quick Translate:",
        quickTranslatePlaceholder: "Type or paste text to translate...",
        openSettingsBtn: "Settings...",
        quitBtn: "Quit"
    )

    // Helper builder for other languages inheriting structure cleanly
    private static func makeLocalized(
        appName: String, appTagline: String, enabled: String, disabled: String,
        tabLanguages: String, tabMouse: String, tabAppearance: String, tabFeatures: String, tabHistory: String,
        appInterfaceLanguage: String, defaultTargetLanguage: String, sourceLanguageLabel: String, autoDetectLanguage: String,
        smartReverseToggle: String, secondaryLanguageLabel: String, dictionaryToggle: String,
        triggerClickTitle: String, triggerHoverTitle: String, triggerInstantTitle: String,
        badgePositionLabel: String, autoDismissLabel: String, secondsUnit: String,
        modifierKeyLabel: String, doubleCopyToggle: String, globalHotkeyLabel: String,
        styleGlassTitle: String, styleCompactTitle: String,
        windowOpacityLabel: String, fontSizeLabel: String, badgeSizeLabel: String, themeModeLabel: String,
        previewButton: String, permissionGrantedTitle: String, permissionMissingTitle: String, grantPermissionBtn: String,
        smartFallbackToggle: String, autoCopyToggle: String, launchAtLoginToggle: String, resetDefaultsBtn: String,
        searchHistoryPlaceholder: String, clearHistoryBtn: String, emptyHistoryText: String,
        translatingText: String, copyBtn: String, copiedBtn: String, replaceBtn: String, openSettingsBtn: String, quitBtn: String
    ) -> AppStrings {
        let base = english
        return AppStrings(
            appName: appName,
            appTagline: appTagline,
            enabled: enabled,
            disabled: disabled,
            tabLanguages: tabLanguages,
            tabMouse: tabMouse,
            tabAppearance: tabAppearance,
            tabFeatures: tabFeatures,
            tabHistory: tabHistory,
            sectionAppLanguage: appInterfaceLanguage,
            appInterfaceLanguage: appInterfaceLanguage,
            appInterfaceLanguageSub: base.appInterfaceLanguageSub,
            sectionTranslationLanguages: tabLanguages,
            defaultTargetLanguage: defaultTargetLanguage,
            defaultTargetLanguageSub: base.defaultTargetLanguageSub,
            sourceLanguageLabel: sourceLanguageLabel,
            sourceLanguageSub: base.sourceLanguageSub,
            autoDetectLanguage: autoDetectLanguage,
            sectionSmartReverse: smartReverseToggle,
            smartReverseToggle: smartReverseToggle,
            smartReverseSub: base.smartReverseSub,
            secondaryLanguageLabel: secondaryLanguageLabel,
            sectionDictionary: dictionaryToggle,
            dictionaryToggle: dictionaryToggle,
            dictionarySub: base.dictionarySub,
            sectionTriggerMode: tabMouse,
            triggerClickTitle: triggerClickTitle,
            triggerClickSub: base.triggerClickSub,
            triggerHoverTitle: triggerHoverTitle,
            triggerHoverSub: base.triggerHoverSub,
            triggerInstantTitle: triggerInstantTitle,
            triggerInstantSub: base.triggerInstantSub,
            sectionBadgePlacement: badgePositionLabel,
            badgePositionLabel: badgePositionLabel,
            posTopRight: base.posTopRight,
            posBottomRight: base.posBottomRight,
            posTopLeft: base.posTopLeft,
            posBottomCenter: base.posBottomCenter,
            autoDismissLabel: autoDismissLabel,
            secondsUnit: secondsUnit,
            sectionShortcuts: globalHotkeyLabel,
            modifierKeyLabel: modifierKeyLabel,
            modNone: base.modNone,
            modOption: base.modOption,
            modCommand: base.modCommand,
            modControl: base.modControl,
            doubleCopyToggle: doubleCopyToggle,
            doubleCopySub: base.doubleCopySub,
            globalHotkeyLabel: globalHotkeyLabel,
            globalHotkeySub: base.globalHotkeySub,
            sectionDisplayStyle: tabAppearance,
            styleGlassTitle: styleGlassTitle,
            styleGlassSub: base.styleGlassSub,
            styleCompactTitle: styleCompactTitle,
            styleCompactSub: base.styleCompactSub,
            sectionVisualTuning: windowOpacityLabel,
            windowOpacityLabel: windowOpacityLabel,
            fontSizeLabel: fontSizeLabel,
            badgeSizeLabel: badgeSizeLabel,
            themeModeLabel: themeModeLabel,
            themeSystem: base.themeSystem,
            themeDark: base.themeDark,
            themeLight: base.themeLight,
            sectionLivePreview: previewButton,
            previewPrompt: base.previewPrompt,
            previewButton: previewButton,
            sectionPermissions: base.sectionPermissions,
            permissionGrantedTitle: permissionGrantedTitle,
            permissionMissingTitle: permissionMissingTitle,
            permissionDesc: base.permissionDesc,
            grantPermissionBtn: grantPermissionBtn,
            refreshStatusBtn: base.refreshStatusBtn,
            sectionAdvanced: tabFeatures,
            smartFallbackToggle: smartFallbackToggle,
            smartFallbackSub: base.smartFallbackSub,
            autoCopyToggle: autoCopyToggle,
            autoCopySub: base.autoCopySub,
            launchAtLoginToggle: launchAtLoginToggle,
            launchAtLoginSub: base.launchAtLoginSub,
            resetDefaultsLabel: resetDefaultsBtn,
            resetDefaultsBtn: resetDefaultsBtn,
            searchHistoryPlaceholder: searchHistoryPlaceholder,
            clearHistoryBtn: clearHistoryBtn,
            emptyHistoryText: emptyHistoryText,
            translatingText: translatingText,
            networkErrorText: base.networkErrorText,
            retryBtn: base.retryBtn,
            copyBtn: copyBtn,
            copiedBtn: copiedBtn,
            replaceBtn: replaceBtn,
            replacedBtn: base.replacedBtn,
            speakTooltip: base.speakTooltip,
            showOriginalBtn: base.showOriginalBtn,
            hideOriginalBtn: base.hideOriginalBtn,
            originalTextHeader: base.originalTextHeader,
            translateToHeader: defaultTargetLanguage,
            quickTranslateHeader: base.quickTranslateHeader,
            quickTranslatePlaceholder: base.quickTranslatePlaceholder,
            openSettingsBtn: openSettingsBtn,
            quitBtn: quitBtn
        )
    }

    // MARK: - 3. French (Français)
    public static let french = makeLocalized(
        appName: "Lamha — Traducteur Instantané",
        appTagline: "Traduction instantanée du texte sélectionné à la souris ou au trackpad",
        enabled: "Actif", disabled: "Pause",
        tabLanguages: "Langues", tabMouse: "Souris", tabAppearance: "Apparence", tabFeatures: "Options", tabHistory: "Historique",
        appInterfaceLanguage: "Langue de l'interface",
        defaultTargetLanguage: "Traduire toujours vers",
        sourceLanguageLabel: "Langue source",
        autoDetectLanguage: "Détection auto",
        smartReverseToggle: "Traduction inversée intelligente",
        secondaryLanguageLabel: "Langue secondaire",
        dictionaryToggle: "Afficher le dictionnaire et les synonymes",
        triggerClickTitle: "Afficher l'icône (Cliquer pour traduire)",
        triggerHoverTitle: "Afficher l'icône (Survoler pour traduire)",
        triggerInstantTitle: "Traduction instantanée dès la sélection",
        badgePositionLabel: "Position de l'icône",
        autoDismissLabel: "Masquer après", secondsUnit: "s",
        modifierKeyLabel: "Touche de modification",
        doubleCopyToggle: "Traduire avec double ⌘C",
        globalHotkeyLabel: "Raccourci global",
        styleGlassTitle: "Fenêtre transparente en verre",
        styleCompactTitle: "Bulle compacte sur place",
        windowOpacityLabel: "Opacité de la fenêtre",
        fontSizeLabel: "Taille de la police",
        badgeSizeLabel: "Taille de l'icône",
        themeModeLabel: "Thème visuel",
        previewButton: "Aperçu en direct",
        permissionGrantedTitle: "Autorisation accordée — Sélection active partout",
        permissionMissingTitle: "Activer l'autorisation Accessibilité",
        grantPermissionBtn: "Ouvrir Réglages",
        smartFallbackToggle: "Capture intelligente pour navigateurs et PDF",
        autoCopyToggle: "Copier automatiquement la traduction",
        launchAtLoginToggle: "Lancer au démarrage du Mac",
        resetDefaultsBtn: "Réinitialiser",
        searchHistoryPlaceholder: "Rechercher dans l'historique...",
        clearHistoryBtn: "Effacer",
        emptyHistoryText: "Aucune traduction dans l'historique",
        translatingText: "Traduction...",
        copyBtn: "Copier", copiedBtn: "Copié", replaceBtn: "Remplacer",
        openSettingsBtn: "Réglages...", quitBtn: "Quitter"
    )

    // MARK: - 4. Spanish (Español)
    public static let spanish = makeLocalized(
        appName: "Lamha — Traductor Instantáneo",
        appTagline: "Traducción ligera e instantánea al seleccionar texto con ratón o trackpad",
        enabled: "Activo", disabled: "Pausado",
        tabLanguages: "Idiomas", tabMouse: "Ratón", tabAppearance: "Apariencia", tabFeatures: "Opciones", tabHistory: "Historial",
        appInterfaceLanguage: "Idioma de la aplicación",
        defaultTargetLanguage: "Traducir siempre a",
        sourceLanguageLabel: "Idioma de origen",
        autoDetectLanguage: "Detectar idioma",
        smartReverseToggle: "Traducción inversa inteligente",
        secondaryLanguageLabel: "Idioma secundario",
        dictionaryToggle: "Mostrar diccionario y sinónimos",
        triggerClickTitle: "Mostrar icono flotante (Clic para traducir)",
        triggerHoverTitle: "Mostrar icono flotante (Pasar cursor para traducir)",
        triggerInstantTitle: "Traducción instantánea al seleccionar",
        badgePositionLabel: "Posición del icono",
        autoDismissLabel: "Ocultar automáticamente tras", secondsUnit: "s",
        modifierKeyLabel: "Tecla modificadora",
        doubleCopyToggle: "Traducir al pulsar ⌘C dos veces",
        globalHotkeyLabel: "Atajo de teclado global",
        styleGlassTitle: "Ventana translúcida de cristal",
        styleCompactTitle: "En el mismo lugar (Compacto)",
        windowOpacityLabel: "Opacidad de la ventana",
        fontSizeLabel: "Tamaño de fuente",
        badgeSizeLabel: "Tamaño del icono",
        themeModeLabel: "Apariencia visual",
        previewButton: "Vista previa",
        permissionGrantedTitle: "Permiso concedido — Selección activa en todo el Mac",
        permissionMissingTitle: "Habilitar permiso de Accesibilidad",
        grantPermissionBtn: "Abrir Ajustes",
        smartFallbackToggle: "Captura inteligente para navegadores y PDF",
        autoCopyToggle: "Copiar traducción automáticamente",
        launchAtLoginToggle: "Iniciar al arrancar el Mac",
        resetDefaultsBtn: "Restablecer",
        searchHistoryPlaceholder: "Buscar en el historial...",
        clearHistoryBtn: "Borrar",
        emptyHistoryText: "Aún no hay traducciones en el historial",
        translatingText: "Traduciendo...",
        copyBtn: "Copiar", copiedBtn: "Copiado", replaceBtn: "Reemplazar",
        openSettingsBtn: "Ajustes...", quitBtn: "Salir"
    )

    // MARK: - 5. German (Deutsch)
    public static let german = makeLocalized(
        appName: "Lamha — Sofortübersetzer",
        appTagline: "Schnelle Sofortübersetzung bei Textauswahl mit Maus oder Trackpad",
        enabled: "Aktiv", disabled: "Pausiert",
        tabLanguages: "Sprachen", tabMouse: "Maus", tabAppearance: "Darstellung", tabFeatures: "Optionen", tabHistory: "Verlauf",
        appInterfaceLanguage: "App-Sprache",
        defaultTargetLanguage: "Immer übersetzen nach",
        sourceLanguageLabel: "Ausgangssprache",
        autoDetectLanguage: "Automatisch erkennen",
        smartReverseToggle: "Intelligente Rückübersetzung",
        secondaryLanguageLabel: "Zweitsprache",
        dictionaryToggle: "Wörterbuch und Synonyme anzeigen",
        triggerClickTitle: "Kleines Symbol zeigen (Klicken zum Übersetzen)",
        triggerHoverTitle: "Kleines Symbol zeigen (Hover zum Übersetzen)",
        triggerInstantTitle: "Sofort при Auswahl übersetzen",
        badgePositionLabel: "Symbolposition",
        autoDismissLabel: "Automatisch ausblenden nach", secondsUnit: "Sek.",
        modifierKeyLabel: "Zusatztaste bei Auswahl",
        doubleCopyToggle: "Bei doppeltem ⌘C übersetzen",
        globalHotkeyLabel: "Globales Tastaturkürzel",
        styleGlassTitle: "Transparentes Glasfenster",
        styleCompactTitle: "Kompakt direkt an der Textstelle",
        windowOpacityLabel: "Fensterdeckkraft",
        fontSizeLabel: "Schriftgröße",
        badgeSizeLabel: "Symbolgröße",
        themeModeLabel: "Erscheinungsbild",
        previewButton: "Vorschau",
        permissionGrantedTitle: "Berechtigung aktiv — Funktioniert systemweit",
        permissionMissingTitle: "Bedienungshilfen-Berechtigung aktivieren",
        grantPermissionBtn: "Einstellungen öffnen",
        smartFallbackToggle: "Intelligente Erfassung für Browser & PDFs",
        autoCopyToggle: "Übersetzung automatisch kopieren",
        launchAtLoginToggle: "Beim Anmelden starten",
        resetDefaultsBtn: "Zurücksetzen",
        searchHistoryPlaceholder: "Verlauf durchsuchen...",
        clearHistoryBtn: "Löschen",
        emptyHistoryText: "Noch keine Übersetzungen im Verlauf",
        translatingText: "Übersetze...",
        copyBtn: "Kopieren", copiedBtn: "Kopiert", replaceBtn: "Ersetzen",
        openSettingsBtn: "Einstellungen...", quitBtn: "Beenden"
    )

    // MARK: - 6. Turkish (Türkçe)
    public static let turkish = makeLocalized(
        appName: "Lamha — Anında Çeviri",
        appTagline: "Fare veya izleme dörtgeni ile seçilen metinler için anında çeviri",
        enabled: "Aktif", disabled: "Duraklatıldı",
        tabLanguages: "Diller", tabMouse: "Fare", tabAppearance: "Görünüm", tabFeatures: "Özellikler", tabHistory: "Geçmiş",
        appInterfaceLanguage: "Uygulama Arayüz Dili",
        defaultTargetLanguage: "Her zaman şu dile çevir",
        sourceLanguageLabel: "Kaynak Dil",
        autoDetectLanguage: "Otomatik Algıla",
        smartReverseToggle: "Akıllı Ters Çeviri",
        secondaryLanguageLabel: "İkincil Hedef Dil",
        dictionaryToggle: "Sözlük anlamlarını ve eş anlamlıları göster",
        triggerClickTitle: "Küçük simge göster (Çevirmek için tıkla)",
        triggerHoverTitle: "Küçük simge göster (Üzerine gelince çevir)",
        triggerInstantTitle: "Seçim yapılır yapılmaz anında çevir",
        badgePositionLabel: "Simge konumu",
        autoDismissLabel: "Otomatik gizleme süresi", secondsUnit: "sn",
        modifierKeyLabel: "Seçim sırasında ek tuş",
        doubleCopyToggle: "Çift ⌘C ile hızlı çeviri",
        globalHotkeyLabel: "Genel Klavye Kısayolu",
        styleGlassTitle: "Şeffaf Cam Pencere",
        styleCompactTitle: "Yerinde Kompakt Görünüm",
        windowOpacityLabel: "Pencere şeffaflığı",
        fontSizeLabel: "Yazı tipi boyutu",
        badgeSizeLabel: "Simge boyutu",
        themeModeLabel: "Tema görünümü",
        previewButton: "Canlı Önizleme",
        permissionGrantedTitle: "İzin Verildi — Tüm Mac'te otomatik çalışıyor",
        permissionMissingTitle: "Erişilebilirlik İznini Etkinleştir",
        grantPermissionBtn: "Ayarları Aç",
        smartFallbackToggle: "Tarayıcılar ve PDF'ler için Akıllı Yakalama",
        autoCopyToggle: "Çeviriyi panoya otomatik kopyala",
        launchAtLoginToggle: "Mac açılışında otomatik başlat",
        resetDefaultsBtn: "Sıfırla",
        searchHistoryPlaceholder: "Geçmişte ara...",
        clearHistoryBtn: "Temizle",
        emptyHistoryText: "Henüz çeviri geçmişi yok",
        translatingText: "Çevriliyor...",
        copyBtn: "Kopyala", copiedBtn: "Kopyalandı", replaceBtn: "Değiştir",
        openSettingsBtn: "Ayarlar...", quitBtn: "Çıkış"
    )

    // MARK: - 7. Russian (Русский)
    public static let russian = makeLocalized(
        appName: "Lamha — Мгновенный переводчик",
        appTagline: "Легкий мгновенный перевод любого выделенного текста на Mac",
        enabled: "Активно", disabled: "Пауза",
        tabLanguages: "Языки", tabMouse: "Мышь", tabAppearance: "Вид", tabFeatures: "Опции", tabHistory: "История",
        appInterfaceLanguage: "Язык интерфейса приложения",
        defaultTargetLanguage: "Всегда переводить на",
        sourceLanguageLabel: "Исходный язык",
        autoDetectLanguage: "Автоопределение",
        smartReverseToggle: "Умный обратный перевод",
        secondaryLanguageLabel: "Дополнительный язык",
        dictionaryToggle: "Показывать словарь и синонимы",
        triggerClickTitle: "Показывать значок (клик для перевода)",
        triggerHoverTitle: "Показывать значок (наведение для перевода)",
        triggerInstantTitle: "Мгновенный перевод при выделении",
        badgePositionLabel: "Позиция значка",
        autoDismissLabel: "Скрывать значок через", secondsUnit: "сек",
        modifierKeyLabel: "Клавиша-модификатор",
        doubleCopyToggle: "Перевод по двойному нажатию ⌘C",
        globalHotkeyLabel: "Глобальное сочетание клавиш",
        styleGlassTitle: "Прозрачное стеклянное окно",
        styleCompactTitle: "Компактно на месте текста",
        windowOpacityLabel: "Прозрачность окна",
        fontSizeLabel: "Размер шрифта",
        badgeSizeLabel: "Размер значка",
        themeModeLabel: "Тема оформления",
        previewButton: "Предпросмотр",
        permissionGrantedTitle: "Доступ разрешен — работает во всех приложениях",
        permissionMissingTitle: "Включите Универсальный доступ",
        grantPermissionBtn: "Открыть настройки",
        smartFallbackToggle: "Умный захват для браузеров и PDF",
        autoCopyToggle: "Автоматически копировать перевод",
        launchAtLoginToggle: "Запускать при входе в систему",
        resetDefaultsBtn: "Сбросить",
        searchHistoryPlaceholder: "Поиск в истории...",
        clearHistoryBtn: "Очистить",
        emptyHistoryText: "История переводов пуста",
        translatingText: "Перевод...",
        copyBtn: "Копировать", copiedBtn: "Скопировано", replaceBtn: "Заменить",
        openSettingsBtn: "Настройки...", quitBtn: "Выйти"
    )

    // MARK: - 8. Chinese Simplified (中文)
    public static let chinese = makeLocalized(
        appName: "Lamha — 极速划词翻译",
        appTagline: "鼠标或触控板选中文本即可在原位或透明窗口中极速翻译",
        enabled: "已启用", disabled: "已暂停",
        tabLanguages: "语言", tabMouse: "鼠标", tabAppearance: "外观", tabFeatures: "功能", tabHistory: "历史",
        appInterfaceLanguage: "应用界面语言",
        defaultTargetLanguage: "始终翻译为目标语言",
        sourceLanguageLabel: "源语言",
        autoDetectLanguage: "自动检测",
        smartReverseToggle: "智能双向互译",
        secondaryLanguageLabel: "第二目标语言",
        dictionaryToggle: "显示词典释义与词性",
        triggerClickTitle: "显示小图标（点击翻译）",
        triggerHoverTitle: "显示小图标（悬停直接翻译）",
        triggerInstantTitle: "选中文本立即翻译",
        badgePositionLabel: "浮动图标位置",
        autoDismissLabel: "自动隐藏图标时间", secondsUnit: "秒",
        modifierKeyLabel: "划词辅助按键",
        doubleCopyToggle: "双击 ⌘C 快速翻译",
        globalHotkeyLabel: "全局快捷键",
        styleGlassTitle: "毛玻璃透明卡片",
        styleCompactTitle: "原位极简内联条",
        windowOpacityLabel: "窗口不透明度",
        fontSizeLabel: "翻译字号",
        badgeSizeLabel: "浮动图标大小",
        themeModeLabel: "主题模式",
        previewButton: "预览翻译窗口",
        permissionGrantedTitle: "辅助功能权限已开启 — 全局划词正常工作",
        permissionMissingTitle: "请开启辅助功能权限以自动获取选中文本",
        grantPermissionBtn: "打开系统设置",
        smartFallbackToggle: "浏览器与 PDF 智能增强取词",
        autoCopyToggle: "翻译后自动复制到剪贴板",
        launchAtLoginToggle: "登录 Mac 时自动启动",
        resetDefaultsBtn: "恢复默认",
        searchHistoryPlaceholder: "搜索翻译历史...",
        clearHistoryBtn: "清空",
        emptyHistoryText: "暂无翻译历史记录",
        translatingText: "正在翻译...",
        copyBtn: "复制", copiedBtn: "已复制", replaceBtn: "替换原文",
        openSettingsBtn: "设置...", quitBtn: "退出"
    )

    // MARK: - 9. Japanese (日本語)
    public static let japanese = makeLocalized(
        appName: "Lamha — 瞬間選択翻訳",
        appTagline: "マウスやトラックパッドで選択したテキストをその場で瞬時に翻訳",
        enabled: "有効", disabled: "停止中",
        tabLanguages: "言語", tabMouse: "マウス", tabAppearance: "外観", tabFeatures: "機能", tabHistory: "履歴",
        appInterfaceLanguage: "アプリの表示言語",
        defaultTargetLanguage: "常に翻訳する言語",
        sourceLanguageLabel: "元の言語",
        autoDetectLanguage: "自動検出",
        smartReverseToggle: "スマート逆翻訳を有効化",
        secondaryLanguageLabel: "第2ターゲット言語",
        dictionaryToggle: "辞書と類義語を表示",
        triggerClickTitle: "ミニアイコンを表示（クリックで翻訳）",
        triggerHoverTitle: "ミニアイコンを表示（ホバーで翻訳）",
        triggerInstantTitle: "選択と同時に即時翻訳",
        badgePositionLabel: "アイコンの表示位置",
        autoDismissLabel: "アイコンを自動で隠す時間", secondsUnit: "秒",
        modifierKeyLabel: "選択時の修飾キー",
        doubleCopyToggle: "⌘C の2回押しで翻訳",
        globalHotkeyLabel: "グローバルショートカット",
        styleGlassTitle: "半透明ガラスカード",
        styleCompactTitle: "インプレース最小バー",
        windowOpacityLabel: "ウィンドウの不透明度",
        fontSizeLabel: "フォントサイズ",
        badgeSizeLabel: "アイコンサイズ",
        themeModeLabel: "外観テーマ",
        previewButton: "プレビュー",
        permissionGrantedTitle: "権限許可済み — すべてのアプリで動作します",
        permissionMissingTitle: "アクセシビリティ権限を有効にしてください",
        grantPermissionBtn: "システム設定を開く",
        smartFallbackToggle: "ブラウザ・PDF用スマートテキスト取得",
        autoCopyToggle: "翻訳結果を自動的にコピー",
        launchAtLoginToggle: "ログイン時に自動起動",
        resetDefaultsBtn: "初期設定に戻す",
        searchHistoryPlaceholder: "履歴を検索...",
        clearHistoryBtn: "履歴を消去",
        emptyHistoryText: "翻訳履歴はまだありません",
        translatingText: "翻訳中...",
        copyBtn: "コピー", copiedBtn: "コピー完了", replaceBtn: "置換",
        openSettingsBtn: "設定...", quitBtn: "終了"
    )

    // MARK: - 10. Korean (한국어)
    public static let korean = makeLocalized(
        appName: "Lamha — 실시간 선택 번역기",
        appTagline: "마우스나 트랙패드로 선택한 텍스트를 즉시 번역합니다",
        enabled: "활성", disabled: "일시중지",
        tabLanguages: "언어", tabMouse: "마우스", tabAppearance: "모양", tabFeatures: "기능", tabHistory: "기록",
        appInterfaceLanguage: "앱 인터페이스 언어",
        defaultTargetLanguage: "기본 번역 대상 언어",
        sourceLanguageLabel: "원본 언어",
        autoDetectLanguage: "자동 감지",
        smartReverseToggle: "스마트 역방향 자동 번역",
        secondaryLanguageLabel: "보조 번역 언어",
        dictionaryToggle: "사전적 의미 및 유의어 표시",
        triggerClickTitle: "작은 아이콘 표시 (클릭하여 번역)",
        triggerHoverTitle: "작은 아이콘 표시 (마우스 오버로 번역)",
        triggerInstantTitle: "텍스트 선택 즉시 번역",
        badgePositionLabel: "아이콘 위치",
        autoDismissLabel: "자동 숨김 시간", secondsUnit: "초",
        modifierKeyLabel: "보조 키 조건",
        doubleCopyToggle: "⌘C 두 번 눌러 번역",
        globalHotkeyLabel: "전역 단축키",
        styleGlassTitle: "반투명 글래스 카드",
        styleCompactTitle: "제자리 미니 오버레이",
        windowOpacityLabel: "창 투명도",
        fontSizeLabel: "글자 크기",
        badgeSizeLabel: "아이콘 크기",
        themeModeLabel: "테마 모드",
        previewButton: "미리보기",
        permissionGrantedTitle: "권한 허용됨 — 모든 앱에서 작동합니다",
        permissionMissingTitle: "손쉬운 사용 권한을 활성화하세요",
        grantPermissionBtn: "설정 열기",
        smartFallbackToggle: "브라우저 및 PDF 스마트 텍스트 캡처",
        autoCopyToggle: "번역 결과 자동 복사",
        launchAtLoginToggle: "로그인 시 자동 실행",
        resetDefaultsBtn: "초기화",
        searchHistoryPlaceholder: "번역 기록 검색...",
        clearHistoryBtn: "기록 삭제",
        emptyHistoryText: "저장된 번역 기록이 없습니다",
        translatingText: "번역 중...",
        copyBtn: "복사", copiedBtn: "복사됨", replaceBtn: "바꾸기",
        openSettingsBtn: "설정...", quitBtn: "종료"
    )

    // MARK: - 11. Italian (Italiano)
    public static let italian = makeLocalized(
        appName: "Lamha — Traduttore Istantaneo",
        appTagline: "Traduzione leggera e immediata del testo selezionato con mouse o trackpad",
        enabled: "Attivo", disabled: "In pausa",
        tabLanguages: "Lingue", tabMouse: "Mouse", tabAppearance: "Aspetto", tabFeatures: "Opzioni", tabHistory: "Cronologia",
        appInterfaceLanguage: "Lingua dell'interfaccia",
        defaultTargetLanguage: "Traduci sempre in",
        sourceLanguageLabel: "Lingua di origine",
        autoDetectLanguage: "Rileva automaticamente",
        smartReverseToggle: "Traduzione inversa intelligente",
        secondaryLanguageLabel: "Lingua secondaria",
        dictionaryToggle: "Mostra dizionario e sinonimi",
        triggerClickTitle: "Mostra icona (Clic per tradurre)",
        triggerHoverTitle: "Mostra icona (Passa sopra per tradurre)",
        triggerInstantTitle: "Traduzione istantanea alla selezione",
        badgePositionLabel: "Posizione dell'icona",
        autoDismissLabel: "Nascondi automaticamente dopo", secondsUnit: "s",
        modifierKeyLabel: "Tasto modificatore",
        doubleCopyToggle: "Traduci con doppio ⌘C",
        globalHotkeyLabel: "Scorciatoia globale",
        styleGlassTitle: "Finestra trasparente in vetro",
        styleCompactTitle: "Compatto sul posto",
        windowOpacityLabel: "Opacità della finestra",
        fontSizeLabel: "Dimensione testo",
        badgeSizeLabel: "Dimensione icona",
        themeModeLabel: "Tema visivo",
        previewButton: "Anteprima",
        permissionGrantedTitle: "Permesso attivo — Funziona ovunque sul Mac",
        permissionMissingTitle: "Abilita il permesso Accessibilità",
        grantPermissionBtn: "Apri Impostazioni",
        smartFallbackToggle: "Acquisizione intelligente per browser e PDF",
        autoCopyToggle: "Copia automaticamente la traduzione",
        launchAtLoginToggle: "Avvia al login del Mac",
        resetDefaultsBtn: "Ripristina",
        searchHistoryPlaceholder: "Cerca nella cronologia...",
        clearHistoryBtn: "Cancella",
        emptyHistoryText: "Nessuna traduzione nella cronologia",
        translatingText: "Traduzione...",
        copyBtn: "Copia", copiedBtn: "Copiato", replaceBtn: "Sostituisci",
        openSettingsBtn: "Impostazioni...", quitBtn: "Esci"
    )

    // MARK: - 12. Portuguese (Português)
    public static let portuguese = makeLocalized(
        appName: "Lamha — Tradutor Instantâneo",
        appTagline: "Tradução leve e imediata para qualquer texto selecionado com mouse ou trackpad",
        enabled: "Ativo", disabled: "Pausado",
        tabLanguages: "Idiomas", tabMouse: "Mouse", tabAppearance: "Aparência", tabFeatures: "Opções", tabHistory: "Histórico",
        appInterfaceLanguage: "Idioma do aplicativo",
        defaultTargetLanguage: "Traduzir sempre para",
        sourceLanguageLabel: "Idioma de origem",
        autoDetectLanguage: "Detectar idioma",
        smartReverseToggle: "Tradução reversa inteligente",
        secondaryLanguageLabel: "Idioma secundário",
        dictionaryToggle: "Mostrar dicionário e sinônimos",
        triggerClickTitle: "Mostrar ícone (Clicar para traduzir)",
        triggerHoverTitle: "Mostrar ícone (Passar o cursor para traduzir)",
        triggerInstantTitle: "Tradução instantânea ao selecionar",
        badgePositionLabel: "Posição do ícone",
        autoDismissLabel: "Ocultar após", secondsUnit: "s",
        modifierKeyLabel: "Tecla modificadora",
        doubleCopyToggle: "Traduzir com duplo ⌘C",
        globalHotkeyLabel: "Atalho global",
        styleGlassTitle: "Janela translúcida de vidro",
        styleCompactTitle: "Compacto no mesmo local",
        windowOpacityLabel: "Opacidade da janela",
        fontSizeLabel: "Tamanho da fonte",
        badgeSizeLabel: "Tamanho do ícone",
        themeModeLabel: "Tema visual",
        previewButton: "Visualizar",
        permissionGrantedTitle: "Permissão concedida — Ativo em todo o Mac",
        permissionMissingTitle: "Ativar permissão de Acessibilidade",
        grantPermissionBtn: "Abrir Ajustes",
        smartFallbackToggle: "Captura inteligente para navegadores e PDFs",
        autoCopyToggle: "Copiar tradução automaticamente",
        launchAtLoginToggle: "Iniciar no login do Mac",
        resetDefaultsBtn: "Redefinir",
        searchHistoryPlaceholder: "Pesquisar no histórico...",
        clearHistoryBtn: "Limpar",
        emptyHistoryText: "Nenhuma tradução no histórico",
        translatingText: "Traduzindo...",
        copyBtn: "Copiar", copiedBtn: "Copiado", replaceBtn: "Substituir",
        openSettingsBtn: "Ajustes...", quitBtn: "Sair"
    )

    // MARK: - 13. Dutch (Nederlands)
    public static let dutch = makeLocalized(
        appName: "Lamha — Directe Vertaler",
        appTagline: "Directe vertaling van geselecteerde tekst met muis of trackpad",
        enabled: "Actief", disabled: "Gepauzeerd",
        tabLanguages: "Talen", tabMouse: "Muis", tabAppearance: "Weergave", tabFeatures: "Opties", tabHistory: "Geschiedenis",
        appInterfaceLanguage: "App-taal",
        defaultTargetLanguage: "Altijd vertalen naar",
        sourceLanguageLabel: "Brontaal",
        autoDetectLanguage: "Automatisch detecteren",
        smartReverseToggle: "Slimme omgekeerde vertaling",
        secondaryLanguageLabel: "Tweede doeltaal",
        dictionaryToggle: "Woordenboek en synoniemen tonen",
        triggerClickTitle: "Klein icoon tonen (Klik om te vertalen)",
        triggerHoverTitle: "Klein icoon tonen (Zweef om te vertalen)",
        triggerInstantTitle: "Direct vertalen bij selectie",
        badgePositionLabel: "Icoonpositie",
        autoDismissLabel: "Automatisch verbergen na", secondsUnit: "s",
        modifierKeyLabel: "Wijzigingstoets",
        doubleCopyToggle: "Vertalen bij dubbel ⌘C",
        globalHotkeyLabel: "Globale sneltoets",
        styleGlassTitle: "Transparant glazen venster",
        styleCompactTitle: "Compact op dezelfde plek",
        windowOpacityLabel: "Vensterdekking",
        fontSizeLabel: "Tekstgrootte",
        badgeSizeLabel: "Icoongrootte",
        themeModeLabel: "Thema",
        previewButton: "Voorbeeld",
        permissionGrantedTitle: "Toestemming verleend — Werkt overal op de Mac",
        permissionMissingTitle: "Schakel Toegankelijkheid in",
        grantPermissionBtn: "Systeeminstellingen",
        smartFallbackToggle: "Slimme tekstselectie voor browsers en pdf's",
        autoCopyToggle: "Vertaling automatisch kopiëren",
        launchAtLoginToggle: "Start bij inloggen",
        resetDefaultsBtn: "Herstellen",
        searchHistoryPlaceholder: "Zoek in geschiedenis...",
        clearHistoryBtn: "Wissen",
        emptyHistoryText: "Nog geen vertalingen in geschiedenis",
        translatingText: "Vertalen...",
        copyBtn: "Kopiëren", copiedBtn: "Gekopieerd", replaceBtn: "Vervangen",
        openSettingsBtn: "Instellingen...", quitBtn: "Stop"
    )

    // MARK: - 14. Hindi (हिन्दी)
    public static let hindi = makeLocalized(
        appName: "लम्हा — त्वरित अनुवादक",
        appTagline: "माउस या ट्रैकपैड से चुने गए किसी भी टेक्स्ट का तुरंत अनुवाद",
        enabled: "सक्रिय", disabled: "रुका हुआ",
        tabLanguages: "भाषाएँ", tabMouse: "माउस", tabAppearance: "दिखावट", tabFeatures: "विशेषताएँ", tabHistory: "इतिहास",
        appInterfaceLanguage: "ऐप की भाषा",
        defaultTargetLanguage: "हमेशा इस भाषा में अनुवाद करें",
        sourceLanguageLabel: "स्रोत भाषा",
        autoDetectLanguage: "स्वतः पहचानें",
        smartReverseToggle: "स्मार्ट विपरीत अनुवाद",
        secondaryLanguageLabel: "द्वितीयक भाषा",
        dictionaryToggle: "शब्दकोश और पर्यायवाची दिखाएँ",
        triggerClickTitle: "छोटा आइकन दिखाएँ (अनुवाद के लिए क्लिक करें)",
        triggerHoverTitle: "छोटा आइकन दिखाएँ (माउस ले जाने पर अनुवाद)",
        triggerInstantTitle: "चयन करते ही तुरंत अनुवाद",
        badgePositionLabel: "आइकन की स्थिति",
        autoDismissLabel: "स्वतः छिपाने का समय", secondsUnit: "सेकंड",
        modifierKeyLabel: "सहायक कुंजी",
        doubleCopyToggle: "दो बार ⌘C दबाने पर अनुवाद",
        globalHotkeyLabel: "ग्लोबल शॉर्टकट",
        styleGlassTitle: "पारदर्शी ग्लास विंडो",
        styleCompactTitle: "उसी स्थान पर कॉम्पैक्ट पट्टी",
        windowOpacityLabel: "विंडो पारदर्शिता",
        fontSizeLabel: "फ़ॉन्ट आकार",
        badgeSizeLabel: "आइकन आकार",
        themeModeLabel: "थीम मोड",
        previewButton: "पूर्वावलोकन",
        permissionGrantedTitle: "अनुमति सक्रिय — पूरे मैक पर काम कर रहा है",
        permissionMissingTitle: "एक्सेसिबिलिटी अनुमति सक्रिय करें",
        grantPermissionBtn: "सेटिंग्स खोलें",
        smartFallbackToggle: "ब्राउज़र और PDF के लिए स्मार्ट कैप्चर",
        autoCopyToggle: "अनुवाद को स्वतः कॉपी करें",
        launchAtLoginToggle: "लॉगिन पर स्वतः प्रारंभ करें",
        resetDefaultsBtn: "रीसेट करें",
        searchHistoryPlaceholder: "इतिहास में खोजें...",
        clearHistoryBtn: "साफ़ करें",
        emptyHistoryText: "अभी तक कोई अनुवाद इतिहास नहीं है",
        translatingText: "अनुवाद हो रहा है...",
        copyBtn: "कॉपी", copiedBtn: "कॉपी हुआ", replaceBtn: "बदलें",
        openSettingsBtn: "सेटिंग्स...", quitBtn: "बंद करें"
    )

    // MARK: - 15. Urdu (اردو - RTL)
    public static let urdu = makeLocalized(
        appName: "لمحہ — فوری مترجم",
        appTagline: "ماؤس یا ٹریک پیڈ سے منتخب کردہ کسی بھی عبارت کا فوری ترجمہ",
        enabled: "فعال", disabled: "معطل",
        tabLanguages: "زبانیں", tabMouse: "ماؤس", tabAppearance: "ظاہری شکل", tabFeatures: "خصوصیات", tabHistory: "تاریخچہ",
        appInterfaceLanguage: "ایپ کی زبان",
        defaultTargetLanguage: "ہمیشہ اس زبان میں ترجمہ کریں",
        sourceLanguageLabel: "ماخذ زبان",
        autoDetectLanguage: "خودکار شناخت",
        smartReverseToggle: "ذہین معکوس ترجمہ",
        secondaryLanguageLabel: "متبادل زبان",
        dictionaryToggle: "لغت اور مترادفات دکھائیں",
        triggerClickTitle: "چھوٹا نشان دکھائیں (ترجمہ کے لیے کلک کریں)",
        triggerHoverTitle: "چھوٹا نشان دکھائیں (ماؤس لے جانے پر ترجمہ)",
        triggerInstantTitle: "منتخب کرتے ہی فوری ترجمہ",
        badgePositionLabel: "نشان کی جگہ",
        autoDismissLabel: "خودکار چھپنے کا وقت", secondsUnit: "سیکنڈ",
        modifierKeyLabel: "اضافی بٹن",
        doubleCopyToggle: "دو بار ⌘C دبانے پر ترجمہ",
        globalHotkeyLabel: "عالمی شارٹ کٹ",
        styleGlassTitle: "شفاف شیشے کی ونڈو",
        styleCompactTitle: "اسی جگہ مختصر پٹی",
        windowOpacityLabel: "ونڈو کی شفافیت",
        fontSizeLabel: "فونٹ سائز",
        badgeSizeLabel: "نشان کا سائز",
        themeModeLabel: "تھیم موڈ",
        previewButton: "معائنہ کریں",
        permissionGrantedTitle: "اجازت فعال ہے — ہر جگہ کام کر رہا ہے",
        permissionMissingTitle: "ایکسیسبیلٹی کی اجازت فعال کریں",
        grantPermissionBtn: "ترتیبات کھولیں",
        smartFallbackToggle: "براؤزرز اور PDF کے لیے ذہین کیپچر",
        autoCopyToggle: "ترجمہ خودکار کاپی کریں",
        launchAtLoginToggle: "میک شروع ہونے پر خودکار چلائیں",
        resetDefaultsBtn: "طے شدہ پرواپس",
        searchHistoryPlaceholder: "تاریخچہ میں تلاش کریں...",
        clearHistoryBtn: "صاف کریں",
        emptyHistoryText: "ابھی تک کوئی ترجمہ محفوظ نہیں ہے",
        translatingText: "ترجمہ ہو رہا ہے...",
        copyBtn: "کاپی", copiedBtn: "کاپی ہو گیا", replaceBtn: "تبدیل کریں",
        openSettingsBtn: "ترتیبات...", quitBtn: "بند کریں"
    )

    // MARK: - 16. Persian (فارسی - RTL)
    public static let persian = makeLocalized(
        appName: "لمحه — مترجم فوری",
        appTagline: "ترجمه فوری و سبک هر متنی که با ماوس یا ترک‌پد انتخاب کنید",
        enabled: "فعال", disabled: "متوقف",
        tabLanguages: "زبان‌ها", tabMouse: "ماوس", tabAppearance: "ظاهر", tabFeatures: "ویژگی‌ها", tabHistory: "تاریخچه",
        appInterfaceLanguage: "زبان رابط کاربری برنامه",
        defaultTargetLanguage: "همیشه به این زبان ترجمه شود",
        sourceLanguageLabel: "زبان مبدا",
        autoDetectLanguage: "تشخیص خودکار",
        smartReverseToggle: "ترجمه معکوس هوشمند",
        secondaryLanguageLabel: "زبان جایگزین",
        dictionaryToggle: "نمایش واژه‌نامه و مترادف‌ها",
        triggerClickTitle: "نمایش نشانگر کوچک (کلیک برای ترجمه)",
        triggerHoverTitle: "نمایش نشانگر کوچک (نگه داشتن ماوس برای ترجمه)",
        triggerInstantTitle: "ترجمه فوری به محض انتخاب متن",
        badgePositionLabel: "موقعیت نشانگر",
        autoDismissLabel: "پنهان شدن خودکار پس از", secondsUnit: "ثانیه",
        modifierKeyLabel: "کلید ترکیبی هنگام انتخاب",
        doubleCopyToggle: "ترجمه با دو بار فشردن ⌘C",
        globalHotkeyLabel: "میانبر سراسری صفحه کلید",
        styleGlassTitle: "پنجره شیشه‌ای شفاف",
        styleCompactTitle: "ترجمه در همان موقعیت (فشرده)",
        windowOpacityLabel: "شفافیت پنجره",
        fontSizeLabel: "اندازه قلم",
        badgeSizeLabel: "اندازه نشانگر شناور",
        themeModeLabel: "حالت ظاهری",
        previewButton: "پیش‌نمایش زنده",
        permissionGrantedTitle: "دسترسی فعال است — در تمام برنامه‌ها کار می‌کند",
        permissionMissingTitle: "فعال‌سازی دسترسی Accessibility",
        grantPermissionBtn: "باز کردن تنظیمات",
        smartFallbackToggle: "دریافت هوشمند متن برای مرورگرها و PDF",
        autoCopyToggle: "کپی خودکار ترجمه در کلیپ‌بورد",
        launchAtLoginToggle: "اجرای خودکار هنگام روشن شدن مک",
        resetDefaultsBtn: "بازنشانی",
        searchHistoryPlaceholder: "جستجو در تاریخچه...",
        clearHistoryBtn: "پاک کردن",
        emptyHistoryText: "هنوز ترجمه‌ای در تاریخچه ذخیره نشده است",
        translatingText: "در حال ترجمه...",
        copyBtn: "کپی", copiedBtn: "کپی شد", replaceBtn: "جایگزینی",
        openSettingsBtn: "تنظیمات...", quitBtn: "خروج"
    )
}
