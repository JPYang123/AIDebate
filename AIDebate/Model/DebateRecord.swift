import Foundation
import RealmSwift

class DebateMessageObject: Object {
    @objc dynamic var speaker: String? = nil
    @objc dynamic var message: String = ""
    @objc dynamic var timestamp: Date = Date()
    @objc dynamic var isSystemMessage: Bool = false

    convenience init(from message: DebateMessage) {
        self.init()
        self.speaker = message.speaker
        self.message = message.message
        self.timestamp = message.timestamp
        self.isSystemMessage = message.isSystemMessage
    }

    func toDebateMessage() -> DebateMessage {
        DebateMessage(
            speaker: speaker,
            message: message,
            timestamp: timestamp,
            isSystemMessage: isSystemMessage
        )
    }
}

class DebateRecord: Object, Identifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var topic: String = ""
    @objc dynamic var date: Date = Date()
    let messages = List<DebateMessageObject>()
}
