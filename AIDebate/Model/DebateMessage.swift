import Foundation

struct DebateMessage: Identifiable, Codable {
    let id = UUID()
    let speaker: String?
    let message: String
    let timestamp: Date
    let isSystemMessage: Bool
}
