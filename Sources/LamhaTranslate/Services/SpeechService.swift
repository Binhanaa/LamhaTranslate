import Foundation
import AVFoundation

@MainActor
public final class SpeechService: NSObject, ObservableObject {
    public static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    @Published public var isSpeaking: Bool = false

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    public func speak(_ text: String, languageCode: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        let mappedLocale = mapToVoiceLocale(languageCode)
        if let voice = AVSpeechSynthesisVoice(language: mappedLocale) ??
                       AVSpeechSynthesisVoice(language: String(languageCode.prefix(2))) {
            utterance.voice = voice
        }
        utterance.rate = 0.48
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    public func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    private func mapToVoiceLocale(_ code: String) -> String {
        switch code.lowercased() {
        case "ar": return "ar-SA"
        case "en": return "en-US"
        case "fr": return "fr-FR"
        case "es": return "es-ES"
        case "de": return "de-DE"
        case "tr": return "tr-TR"
        case "ru": return "ru-RU"
        case "zh", "zh-cn": return "zh-CN"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "it": return "it-IT"
        case "pt": return "pt-BR"
        case "nl": return "nl-NL"
        case "hi": return "hi-IN"
        default: return code
        }
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }

    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}
