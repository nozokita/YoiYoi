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
    var coachPersonality: CoachPersonality = .friendly
    var hydrationIntervalMinutes: Int = 30
    var lastOrderReminderEnabled = true
    private(set) var presets: [QuickDrinkPreset] = []
    private(set) var recentRecords: [DrinkRecord] = []
    private(set) var activeSession: DrinkingSession?

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
            return "設定した目安まであと \(remaining)g"
        case .en:
            if p >= 100 {
                return "Past today's goal—you're OK!"
            }
            if p >= 80 {
                return "Easy does it—you're close to the limit."
            }
            let remaining = Int(AlcoholCalculator.remainingToday(consumed: todayConsumed, dailyGoal: dailyGoal))
            return "\(remaining)g until your set guide."
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
            coachPersonality = CoachPersonality(rawValue: p.aiCoachPersonality) ?? .friendly
            hydrationIntervalMinutes = p.hydrationIntervalMinutes
            lastOrderReminderEnabled = p.lastOrderReminderEnabled
        }

        presets = (try? modelContext.fetch(
            FetchDescriptor<QuickDrinkPreset>(sortBy: [SortDescriptor(\.sortOrder)])
        )) ?? []
        recentRecords = QuickDrinkService.recentUnique(from: allRecords)
        activeSession = SessionManager.activeSession(
            in: (try? modelContext.fetch(
                FetchDescriptor<DrinkingSession>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
            )) ?? []
        )

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
