import Foundation
import Observation

struct CoachDrinkTrend: Equatable {
    let steadyRawType: String?
    let steadyAverageGrams: Int
    let riskyRawType: String?
    let riskyAverageGrams: Int
}

/// ホーム集計（SwiftData の `DrinkRecord` + `UserProfile`）。
@Observable
@MainActor
final class HomeViewModel {
    var todayConsumed: Double = 0
    var weeklyConsumed: Double = 0
    var yesterdayConsumed: Double = 0
    var dailyGoal: Double = 40
    var weeklyGoal: Double = 280
    var streakDays: Int = 0
    var restDaysThisWeek: Int = 0
    var coachDrinkTrend = CoachDrinkTrend(steadyRawType: nil, steadyAverageGrams: 0, riskyRawType: nil, riskyAverageGrams: 0)
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
                return "今日の目安を超えています"
            }
            if p >= 80 {
                return "目安に近づいています"
            }
            let remaining = Int(AlcoholCalculator.remainingToday(consumed: todayConsumed, dailyGoal: dailyGoal))
            return "設定した目安まであと\(remaining)g"
        case .en:
            if p >= 100 {
                return "Over today’s guide"
            }
            if p >= 80 {
                return "Close to today’s guide"
            }
            let remaining = Int(AlcoholCalculator.remainingToday(consumed: todayConsumed, dailyGoal: dailyGoal))
            return "\(remaining)g until today’s guide"
        }
    }

    private(set) var todaysDrinkRecords: [DrinkRecord] = []

    func applyQuickRecord(_ record: DrinkRecord, calendar: Calendar = .current) {
        let now = Date()
        if calendar.isDate(record.loggedAt, inSameDayAs: now) {
            todayConsumed += record.pureAlcoholGrams
            todaysDrinkRecords.insert(record, at: 0)
        }
        if calendar.isDate(record.loggedAt, equalTo: now, toGranularity: .weekOfYear) {
            weeklyConsumed += record.pureAlcoholGrams
        }
        recentRecords = QuickDrinkService.recentUnique(from: [record] + recentRecords)
    }

    func removeQuickRecord(_ record: DrinkRecord, calendar: Calendar = .current) {
        let now = Date()
        if calendar.isDate(record.loggedAt, inSameDayAs: now) {
            todayConsumed = max(0, todayConsumed - record.pureAlcoholGrams)
            todaysDrinkRecords.removeAll { $0.id == record.id }
        }
        if calendar.isDate(record.loggedAt, equalTo: now, toGranularity: .weekOfYear) {
            weeklyConsumed = max(0, weeklyConsumed - record.pureAlcoholGrams)
        }
        recentRecords.removeAll { $0.id == record.id }
    }

    func setActiveSession(_ session: DrinkingSession?) {
        activeSession = session
    }

    func refresh(
        records allRecords: [DrinkRecord],
        profiles: [UserProfile],
        presets quickPresets: [QuickDrinkPreset],
        sessions: [DrinkingSession]
    ) {
        let calendar = Calendar.current
        let now = Date()

        if let p = profiles.first {
            dailyGoal = p.dailyGoalGrams
            weeklyGoal = p.weeklyGoalGrams
            coachPersonality = CoachPersonality(rawValue: p.aiCoachPersonality) ?? .friendly
            hydrationIntervalMinutes = p.hydrationIntervalMinutes
            lastOrderReminderEnabled = p.lastOrderReminderEnabled
        }

        presets = quickPresets
        recentRecords = QuickDrinkService.recentUnique(from: allRecords)
        activeSession = SessionManager.activeSession(in: sessions)

        todayConsumed = AlcoholCalculator.dailyTotal(gramsFrom: allRecords, on: now, calendar: calendar)
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) {
            yesterdayConsumed = AlcoholCalculator.dailyTotal(gramsFrom: allRecords, on: yesterday, calendar: calendar)
        } else {
            yesterdayConsumed = 0
        }
        weeklyConsumed = AlcoholCalculator.weeklyTotal(gramsFrom: allRecords, inWeekOf: now, calendar: calendar)
        coachDrinkTrend = makeDrinkTrend(from: allRecords, calendar: calendar, now: now)
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

    private func makeDrinkTrend(from records: [DrinkRecord], calendar: Calendar, now: Date) -> CoachDrinkTrend {
        let startOfToday = calendar.startOfDay(for: now)
        let pastRecords = records.filter { $0.loggedAt < startOfToday }
        let grouped = Dictionary(grouping: pastRecords, by: \.drinkType)
        let stats = grouped.compactMap { rawType, typeRecords -> (rawType: String, average: Int, count: Int)? in
            guard typeRecords.count >= 2 else { return nil }
            let average = typeRecords.reduce(0) { $0 + $1.pureAlcoholGrams } / Double(typeRecords.count)
            return (rawType, Int(average.rounded()), typeRecords.count)
        }
        guard !stats.isEmpty else {
            return CoachDrinkTrend(steadyRawType: nil, steadyAverageGrams: 0, riskyRawType: nil, riskyAverageGrams: 0)
        }

        let riskyThreshold = dailyGoal * 0.8
        let risky = stats
            .filter { Double($0.average) >= riskyThreshold }
            .max { $0.average < $1.average }
        let steady = stats
            .filter { stat in
                guard stat.rawType != risky?.rawType else { return false }
                return Double(stat.average) < riskyThreshold
            }
            .min { $0.average < $1.average }

        return CoachDrinkTrend(
            steadyRawType: steady?.rawType,
            steadyAverageGrams: steady?.average ?? 0,
            riskyRawType: risky?.rawType,
            riskyAverageGrams: risky?.average ?? 0
        )
    }
}
