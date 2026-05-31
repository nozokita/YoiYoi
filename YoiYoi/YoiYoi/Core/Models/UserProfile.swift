import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID = UUID()
    var gender: String = "male"
    var weeklyGoalGrams: Double = 280
    var dailyGoalGrams: Double = 40
    var language: String = "ja"
    var aiCoachPersonality: String = CoachPersonality.friendly.rawValue
    var hydrationIntervalMinutes: Int = 30
    var lastOrderReminderEnabled: Bool = true
    /// Phase 4 で `AppState` の UserDefaults フラグと同期すること（SPEC「オンボーディング状態の二重管理」参照）。
    var onboardingCompleted: Bool = false
    var createdAt: Date = Date()

    init() {}
}
