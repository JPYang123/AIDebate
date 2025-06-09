import Foundation
import AVFoundation

/// Service that converts text to speech using OpenAI's `gpt-4o-mini-tts` model.
class TextToSpeechService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isSpeaking = false

    private var audioPlayer: AVAudioPlayer?

    /// Generate speech for the provided text and play it back.
    /// - Parameters:
    ///   - text: The text to convert.
    ///   - voice: OpenAI voice identifier. Defaults to "nova".
    ///   - apiKey: OpenAI API key.
    func speak(text: String, voice: String = "nova", apiKey: String) async throws {
        await stop()

        guard !apiKey.isEmpty else {
            throw NSError(domain: "TextToSpeechService", code: 1, userInfo: [NSLocalizedDescriptionKey: "OpenAI API Key is missing."])
        }

        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini-tts",
            "input": text,
            "voice": voice.lowercased(),
            "response_format": "mp3"
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "TextToSpeechService", code: status, userInfo: [NSLocalizedDescriptionKey: "Invalid response from OpenAI. Status: \(status)"])
        }

        try playAudio(data: data)
    }

    private func playAudio(data: Data) throws {
        DispatchQueue.main.async {
            do {
                self.audioPlayer = try AVAudioPlayer(data: data)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.play()
                self.isSpeaking = true
            } catch {
                print("❌ AVAudioPlayer initialization failed: \(error.localizedDescription)")
                self.isSpeaking = false
            }
        }
    }
    /// Stop playback immediately.
    @MainActor
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isSpeaking = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
}
