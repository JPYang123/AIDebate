import SwiftUI

struct MessageView: View {
    let message: DebateMessage
    let onSpeak: (DebateMessage) -> Void
    
    var isAffirmative: Bool {
        message.speaker?.contains("Affirmative") == true
    }
    
    var isOpposition: Bool {
        message.speaker?.contains("Opposition") == true
    }
    
    var body: some View {
        HStack {
            if isOpposition { Spacer(minLength: 40) }
            
            VStack(alignment: .leading, spacing: 6) {
                if let speaker = message.speaker {
                    HStack {
                        Text(speaker)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            onSpeak(message)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Text(message.message)
                    .font(.body)
            }
            .padding(10)
            .background(bubbleColor)
            .cornerRadius(12)
            
            if isAffirmative { Spacer(minLength: 40) }
        }
        .padding(.vertical, 2)
    }
    
    private var bubbleColor: Color {
        if message.isSystemMessage {
            return Color.gray.opacity(0.15)
        } else if isAffirmative {
            return Color.blue.opacity(0.15)
        } else if isOpposition {
            return Color.red.opacity(0.15)
        }
        return Color.gray.opacity(0.15)
    }
}
