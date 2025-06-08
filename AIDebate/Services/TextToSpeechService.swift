import Foundation
import AVFoundation

// MARK: - Text-to-Speech Service
class TextToSpeechService: ObservableObject {
    private let speechSynthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    func speak(text: String, language: String = "zh-CN") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5
        
        speechSynthesizer.speak(utterance)
        isSpeaking = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isSpeaking = false
        }
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    private func detectLanguage(text: String) -> String {
        let chineseRange = text.range(of: "[\u{4e00}-\u{9fff}]", options: .regularExpression)
        return chineseRange != nil ? "zh-CN" : "en-US"
    }
}
