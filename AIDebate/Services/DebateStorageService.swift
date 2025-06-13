import Foundation
import RealmSwift

class DebateStorageService {
    private let realm: Realm

    init() {
        realm = try! Realm()
    }

    func saveDebate(topic: String, messages: [DebateMessage]) {
        let record = DebateRecord()
        record.topic = topic
        record.date = Date()
        let converted = messages.map { DebateMessageObject(from: $0) }
        record.messages.append(objectsIn: converted)
        try? realm.write {
            realm.add(record)
        }
    }

    func fetchDebates() -> [DebateRecord] {
        let results = realm.objects(DebateRecord.self).sorted(byKeyPath: "date", ascending: false)
        return Array(results)
    }

    func deleteDebate(_ debate: DebateRecord) {
        try? realm.write {
            realm.delete(debate.messages)
            realm.delete(debate)
        }
    }
}
