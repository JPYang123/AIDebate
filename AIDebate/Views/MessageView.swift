import SwiftUI

struct MessageView: View {
    let message: DebateMessage
    let onSpeak: (DebateMessage) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let speaker = message.speaker {
                HStack {
                    Text(speaker)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(speaker.contains("Affirmative") ? .blue : .red)
                    
                    Spacer()
                    
                    Button(action: {
                        onSpeak(message)
                    }) {
                        Image(systemName: "speaker.2")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(message.message)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            if message.isSystemMessage {
                Divider()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(message.isSystemMessage ? Color.gray.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
