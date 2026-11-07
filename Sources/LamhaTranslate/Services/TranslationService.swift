import Foundation

public struct DictionaryEntry: Identifiable, Equatable {
    public let id = UUID()
    public let partOfSpeech: String
    public let terms: [String]
}

public struct TranslationResult: Equatable {
    public let originalText: String
    public let translatedText: String
    public let detectedSourceLanguage: String
    public let targetLanguage: String
    public let dictionaryEntries: [DictionaryEntry]
    public let phonetic: String?
}

@MainActor
public final class TranslationService {
    public static let shared = TranslationService()

    private var cache: [String: TranslationResult] = [:]
    private var inFlightTasks: [String: Task<TranslationResult, Error>] = [:]
    private let fastSession: URLSession

    private init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 8
        config.httpMaximumConnectionsPerHost = 6
        config.waitsForConnectivity = false
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.fastSession = URLSession(configuration: config)
    }

    /// Pre-warms DNS + TCP + TLS 1.3 connection to translate.googleapis.com at app launch
    public func warmUpConnection() {
        Task.detached(priority: .utility) {
            guard let url = URL(string: "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=ar&dt=t&dj=1&q=ok") else {
                return
            }
            var req = URLRequest(url: url)
            req.timeoutInterval = 3
            _ = try? await URLSession.shared.data(for: req)
        }
    }

    /// Heuristic to detect if text is predominantly Arabic script
    public nonisolated static func containsPredominantlyArabic(_ text: String) -> Bool {
        var arabicCount = 0
        var letterCount = 0
        for scalar in text.unicodeScalars {
            if CharacterSet.letters.contains(scalar) {
                letterCount += 1
                if (0x0600...0x06FF).contains(scalar.value) ||
                   (0x0750...0x077F).contains(scalar.value) ||
                   (0x08A0...0x08FF).contains(scalar.value) ||
                   (0xFB50...0xFDFF).contains(scalar.value) ||
                   (0xFE70...0xFEFF).contains(scalar.value) {
                    arabicCount += 1
                }
            }
        }
        guard letterCount > 0 else { return false }
        return Double(arabicCount) / Double(letterCount) > 0.5
    }

    private func resolvedCacheKey(for text: String, sourceLang: String? = nil, targetLang: String? = nil) -> (cleaned: String, src: String, tgt: String, key: String) {
        let settings = AppSettings.shared
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let src = sourceLang ?? settings.sourceLanguage
        var tgt = targetLang ?? settings.targetLanguage

        if targetLang == nil && settings.smartReverseTranslation {
            if tgt == "ar" && Self.containsPredominantlyArabic(cleaned) {
                tgt = settings.secondaryLanguage
            }
        }
        return (cleaned, src, tgt, "\(src)|\(tgt)|\(cleaned)")
    }

    /// Synchronous 0ms cache lookup for instant popup rendering without a loading spinner
    public func cachedResult(
        for text: String,
        sourceLang: String? = nil,
        targetLang: String? = nil
    ) -> TranslationResult? {
        let info = resolvedCacheKey(for: text, sourceLang: sourceLang, targetLang: targetLang)
        guard !info.cleaned.isEmpty else { return nil }
        return cache[info.key]
    }

    /// Starts pre-translating immediately when text is selected so it's ready before the user clicks the badge
    public func prefetch(text: String) {
        let info = resolvedCacheKey(for: text)
        guard !info.cleaned.isEmpty, cache[info.key] == nil, inFlightTasks[info.key] == nil else {
            return
        }
        Task {
            _ = try? await translate(text: info.cleaned)
        }
    }

    public func translate(
        text: String,
        sourceLang: String? = nil,
        targetLang: String? = nil
    ) async throws -> TranslationResult {
        let settings = AppSettings.shared
        let info = resolvedCacheKey(for: text, sourceLang: sourceLang, targetLang: targetLang)
        let cleaned = info.cleaned
        let src = info.src
        let tgt = info.tgt
        let cacheKey = info.key

        guard !cleaned.isEmpty else {
            throw NSError(domain: "LamhaTranslate", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty text"])
        }

        if let cached = cache[cacheKey] {
            return cached
        }

        if let existingTask = inFlightTasks[cacheKey] {
            return try await existingTask.value
        }

        let task = Task<TranslationResult, Error> { @MainActor in
            defer { self.inFlightTasks.removeValue(forKey: cacheKey) }

            let result = try await self.performGoogleGTXTranslation(text: cleaned, sourceLang: src, targetLang: tgt)

            if targetLang == nil &&
               settings.smartReverseTranslation &&
               result.detectedSourceLanguage.lowercased().hasPrefix(tgt.lowercased()) &&
               settings.secondaryLanguage.lowercased() != tgt.lowercased() {
                let reverseTarget = settings.secondaryLanguage
                let reverseResult = try await self.performGoogleGTXTranslation(
                    text: cleaned,
                    sourceLang: result.detectedSourceLanguage,
                    targetLang: reverseTarget
                )
                self.cache[cacheKey] = reverseResult
                settings.addHistoryItem(
                    sourceText: cleaned,
                    translatedText: reverseResult.translatedText,
                    sourceLang: reverseResult.detectedSourceLanguage,
                    targetLang: reverseResult.targetLanguage
                )
                return reverseResult
            }

            self.cache[cacheKey] = result
            settings.addHistoryItem(
                sourceText: cleaned,
                translatedText: result.translatedText,
                sourceLang: result.detectedSourceLanguage,
                targetLang: result.targetLanguage
            )
            return result
        }

        inFlightTasks[cacheKey] = task
        return try await task.value
    }

    private func performGoogleGTXTranslation(
        text: String,
        sourceLang: String,
        targetLang: String
    ) async throws -> TranslationResult {
        do {
            return try await requestTranslateEndpoint(
                client: "gtx",
                text: text,
                sourceLang: sourceLang,
                targetLang: targetLang
            )
        } catch {
            return try await requestTranslateEndpoint(
                client: "dict-chrome-ex",
                text: text,
                sourceLang: sourceLang,
                targetLang: targetLang
            )
        }
    }

    private func requestTranslateEndpoint(
        client: String,
        text: String,
        sourceLang: String,
        targetLang: String
    ) async throws -> TranslationResult {
        var components = URLComponents(string: "https://translate.googleapis.com/translate_a/single")!
        components.queryItems = [
            URLQueryItem(name: "client", value: client),
            URLQueryItem(name: "sl", value: sourceLang),
            URLQueryItem(name: "tl", value: targetLang),
            URLQueryItem(name: "dt", value: "t"),
            URLQueryItem(name: "dt", value: "bd"),
            URLQueryItem(name: "dt", value: "rm"),
            URLQueryItem(name: "dj", value: "1"),
            URLQueryItem(name: "q", value: text)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 (KHTML, like Gecko)",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, response) = try await fastSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        guard let json else {
            throw URLError(.cannotParseResponse)
        }

        var translatedParts: [String] = []
        var phoneticText: String? = nil

        if let sentences = json["sentences"] as? [[String: Any]] {
            for sentence in sentences {
                if let trans = sentence["trans"] as? String {
                    translatedParts.append(trans)
                }
                if let translit = sentence["src_translit"] as? String, !translit.isEmpty {
                    phoneticText = translit
                } else if let translit = sentence["translit"] as? String, !translit.isEmpty {
                    phoneticText = translit
                }
            }
        }

        let finalTranslation = translatedParts.joined().trimmingCharacters(in: .whitespacesAndNewlines)
        let detectedSrc = (json["src"] as? String) ?? sourceLang

        var dictEntries: [DictionaryEntry] = []
        if let dictArray = json["dict"] as? [[String: Any]] {
            for entry in dictArray {
                let pos = (entry["pos"] as? String) ?? ""
                let terms = (entry["terms"] as? [String]) ?? []
                if !terms.isEmpty {
                    dictEntries.append(DictionaryEntry(
                        partOfSpeech: localizePartOfSpeech(pos),
                        terms: Array(terms.prefix(5))
                    ))
                }
            }
        }

        return TranslationResult(
            originalText: text,
            translatedText: finalTranslation.isEmpty ? text : finalTranslation,
            detectedSourceLanguage: detectedSrc,
            targetLanguage: targetLang,
            dictionaryEntries: dictEntries,
            phonetic: phoneticText
        )
    }

    private func localizePartOfSpeech(_ pos: String) -> String {
        let isArabicUI = AppSettings.shared.effectiveAppLanguage.lowercased() == "ar"
        guard isArabicUI else { return pos }
        switch pos.lowercased() {
        case "noun": return "اسم"
        case "verb": return "فعل"
        case "adjective": return "صفة"
        case "adverb": return "ظرف"
        case "pronoun": return "ضمير"
        case "preposition": return "حرف جر"
        case "conjunction": return "حرف عطف"
        case "interjection": return "تعجب"
        case "abbreviation": return "اختصار"
        case "phrase": return "عبارة"
        default: return pos
        }
    }
}
