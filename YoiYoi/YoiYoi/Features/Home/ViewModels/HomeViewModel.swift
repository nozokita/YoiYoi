import Foundation
import Observation
import SwiftData

/// ホーム集計（SwiftData の `DrinkRecord` + `UserProfile`）。
@Observable
@MainActor
final class HomeViewModel {
    var todayConsumed: Double = 0
    var weeklyConsumed: Double = 0
    var dailyGoal: Double = 40
    var weeklyGoal: Double = 280
    var streakDays: Int = 0
    var restDaysThisWeek: Int = 0

    var nicknameFlag: String = "🇯🇵"
    var nicknameEmoji: String = "🌙"
    var nicknameAdjective: String = "ほろよい"
    var nicknameNoun: String = "ペンギン"

    /// ヒーロー上段（DESIGN: 15pt Medium white 85%）
    func nicknameLine(language: SupportedLanguage) -> String {
        switch language {
        case .ja:
            "\(nicknameFlag)\(nicknameEmoji) \(nicknameAdjective)\(nicknameNoun) さん"
        case .en:
            "\(nicknameFlag)\(nicknameEmoji) \(nicknameAdjective)\(nicknameNoun)"
        }
    }

    /// メーター下サブテキスト（状態別表現）
    func meterSubtext(language: SupportedLanguage) -> String {
        let p = AlcoholCalculator.percentage(consumed: todayConsumed, goal: dailyGoal)
        switch language {
        case .ja:
            if p >= 100 {
                return "今日はオーバー…でも大丈夫！"
            }
            if p >= 80 {
                return "そろそろ気をつけて！"
            }
            let remaining = Int(AlcoholCalculator.remainingToday(consumed: todayConsumed, dailyGoal: dailyGoal))
            return "あと \(remaining)g 飲めるよ！"
        case .en:
            if p >= 100 {
                return "Past today's goal—you're OK!"
            }
            if p >= 80 {
                return "Easy does it—you're close to the limit."
            }
            let remaining = Int(AlcoholCalculator.remainingToday(consumed: todayConsumed, dailyGoal: dailyGoal))
            return "About \(remaining)g left today."
        }
    }

    private(set) var todaysDrinkRecords: [DrinkRecord] = []

    func refresh(modelContext: ModelContext) {
        let calendar = Calendar.current
        let now = Date()

        let recordDescriptor = FetchDescriptor<DrinkRecord>(
            sortBy: [SortDescriptor(\.loggedAt, order: .reverse)]
        )
        let allRecords = (try? modelContext.fetch(recordDescriptor)) ?? []

        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profiles = (try? modelContext.fetch(profileDescriptor)) ?? []
        if let p = profiles.first {
            dailyGoal = p.dailyGoalGrams
            weeklyGoal = p.weeklyGoalGrams
            nicknameFlag = p.nicknameFlag
            nicknameEmoji = p.nicknameEmoji
            nicknameAdjective = p.nicknameAdjective
            nicknameNoun = p.nicknameNoun
        }

        todayConsumed = AlcoholCalculator.dailyTotal(gramsFrom: allRecords, on: now, calendar: calendar)
        weeklyConsumed = AlcoholCalculator.weeklyTotal(gramsFrom: allRecords, inWeekOf: now, calendar: calendar)
        streakDays = AlcoholCalculator.streakDays(
            gramsFrom: allRecords,
            dailyGoalGrams: dailyGoal,
            endingOn: now,
            calendar: calendar
        )
        restDaysThisWeek = AlcoholCalculator.restDaysInWeek(gramsFrom: allRecords, containing: now, calendar: calendar)

        let startOfToday = calendar.startOfDay(for: now)
        todaysDrinkRecords = allRecords.filter { calendar.isDate($0.loggedAt, inSameDayAs: startOfToday) }
    }
}
