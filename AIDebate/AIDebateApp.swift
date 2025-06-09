import SwiftUI
import AVFoundation // Import the AVFoundation framework

@main
struct AIDebateApp: App {
    // 1. Add this initializer
    init() {
        setupAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    // 2. Add this helper function
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}
