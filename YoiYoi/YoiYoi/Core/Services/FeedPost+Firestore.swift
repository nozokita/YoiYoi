import FirebaseFirestore
import Foundation

extension FeedPost {
    /// Firestore `feed/{documentID}` 用ペイロード（`created_at` は Timestamp）。
    func firestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "uid": uid,
            "type": type.rawValue,
            "actual_grams": actualGrams,
            "goal_grams": goalGrams,
            "percentage": percentage,
            "drinks": drinks,
            "streak_days": streakDays,
            "message_variant": messageVariant,
            "language": language,
            "reactions": [
                "clap": reactions.clap,
                "fire": reactions.fire,
                "muscle": reactions.muscle,
                "hug": reactions.hug,
                "clover": reactions.clover,
                "cheers": reactions.cheers,
            ],
            "reacted_uids": reactedUIDs,
        ]
        if let createdAt {
            data["created_at"] = Timestamp(date: createdAt)
        }
        return data
    }

    init?(document: DocumentSnapshot) {
        guard document.exists, let data = document.data() else { return nil }
        guard let uid = data["uid"] as? String,
              let typeRaw = data["type"] as? String,
              let type = Kind(rawValue: typeRaw),
              let drinks = data["drinks"] as? [String],
              let language = data["language"] as? String,
              let reactedUIDs = data["reacted_uids"] as? [String]
        else {
            return nil
        }

        func double(_ key: String) -> Double? {
            if let d = data[key] as? Double { return d }
            if let n = data[key] as? NSNumber { return n.doubleValue }
            return nil
        }
        func int(_ key: String) -> Int? {
            if let i = data[key] as? Int { return i }
            if let n = data[key] as? NSNumber { return n.intValue }
            return nil
        }

        guard let actualGrams = double("actual_grams"),
              let goalGrams = double("goal_grams"),
              let percentage = double("percentage"),
              let streakDays = int("streak_days"),
              let messageVariant = int("message_variant")
        else {
            return nil
        }

        let reactionsMap = data["reactions"] as? [String: Any] ?? [:]
        func int(_ key: String) -> Int {
            if let i = reactionsMap[key] as? Int { return i }
            if let n = reactionsMap[key] as? NSNumber { return n.intValue }
            return 0
        }
        let reactions = ReactionCounts(
            clap: int("clap"),
            fire: int("fire"),
            muscle: int("muscle"),
            hug: int("hug"),
            clover: int("clover"),
            cheers: int("cheers")
        )

        var createdAt: Date?
        if let ts = data["created_at"] as? Timestamp {
            createdAt = ts.dateValue()
        }

        self.init(
            documentID: document.documentID,
            uid: uid,
            type: type,
            actualGrams: actualGrams,
            goalGrams: goalGrams,
            percentage: percentage,
            drinks: drinks,
            streakDays: streakDays,
            messageVariant: messageVariant,
            language: language,
            reactions: reactions,
            reactedUIDs: reactedUIDs,
            createdAt: createdAt
        )
    }
}
