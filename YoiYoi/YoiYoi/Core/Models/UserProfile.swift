import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID = UUID()
    var firebaseUID: String = ""
    var nicknameFlag: String = "🇯🇵"
    var nicknameEmoji: String = "🌙"
    var nicknameAdjective: String = "ほろよい"
    var nicknameNoun: String = "ペンギン"
    var gender: String = "male"
    var weeklyGoalGrams: Double = 280
    var dailyGoalGrams: Double = 40
    var language: String = "ja"
    /// Phase 4 で `AppState` の UserDefaults フラグと同期すること（SPEC「オンボーディング状態の二重管理」参照）。
    var onboardingCompleted: Bool = false
    var eulaAccepted: Bool = false
    var eulaAcceptedAt: Date? = nil
    var createdAt: Date = Date()
    /// `[String]` を素で持つと Core Data 層で型解決に失敗することがあるため JSON で保持する。
    var blockedUIDsData: Data = Data()

    var blockedUIDs: [String] {
        get { (try? JSONDecoder().decode([String].self, from: blockedUIDsData)) ?? [] }
        set { blockedUIDsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    init() {}
}
