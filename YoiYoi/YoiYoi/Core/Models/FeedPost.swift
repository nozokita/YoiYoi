import Foundation

/// Firestore `feed/{id}` のクライアント側表現（Codable）。`created_at` はエンコード層で Timestamp に載せ替え想定。
struct FeedPost: Codable, Equatable, Identifiable, Sendable {
    enum Kind: String, Codable, Hashable, Sendable {
        case goalMet = "goal_met"
        case restDay = "rest_day"
        case overGoal = "over_goal"
        case weeklyAchieved = "weekly_achieved"
    }

    struct ReactionCounts: Codable, Equatable, Sendable {
        var clap: Int
        var fire: Int
        var muscle: Int
        var hug: Int
        var clover: Int
        var cheers: Int

        static let zero = ReactionCounts(clap: 0, fire: 0, muscle: 0, hug: 0, clover: 0, cheers: 0)
    }

    /// Firestore ドキュメントパス（デコード後にサービス層で設定）。`CodingKeys` から除外。
    var documentID: String = UUID().uuidString

    var id: String { documentID }

    var uid: String
    var type: Kind
    var actualGrams: Double
    var goalGrams: Double
    var percentage: Double
    var drinks: [String]
    var streakDays: Int
    var messageVariant: Int
    var language: String
    var reactions: ReactionCounts
    var reactedUIDs: [String]
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case uid
        case type
        case actualGrams = "actual_grams"
        case goalGrams = "goal_grams"
        case percentage
        case drinks
        case streakDays = "streak_days"
        case messageVariant = "message_variant"
        case language
        case reactions
        case reactedUIDs = "reacted_uids"
        case createdAt = "created_at"
    }
}
