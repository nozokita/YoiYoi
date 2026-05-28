import Foundation
import Observation

struct CoachDrinkTrend: Equatable {
    let steadyRawType: String?
    let steadyAverageGrams: Int
    let riskyRawType: String?
    let riskyAverageGrams: Int
}

struct CoachBehaviorContext: Equatable {
    var todaysRecordCount = 0
    var latestDrinkGrams = 0
    var minutesSinceLastDrink: Int?
    var recentLogGapMinutes: Int?
    var loggingStreakDays = 0
    var plannedDrinkRawType: String?
    var plannedDrinkCount = 1
    var plannedDrinkVolumeML = 0
    var riskyWeekday: Int?
    var riskyTimeSlot: String?
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
    var coachBehavior = CoachBehaviorContext()
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
        coachBehavior = makeBehaviorContext(from: allRecords, calendar: calendar, now: now)
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

    private func makeBehaviorContext(from records: [DrinkRecord], calendar: Calendar, now: Date) -> CoachBehaviorContext {
        let startOfToday = calendar.startOfDay(for: now)
        let todaysRecords = records
            .filter { calendar.isDate($0.loggedAt, inSameDayAs: startOfToday) }
            .sorted { $0.loggedAt > $1.loggedAt }
        let latest = todaysRecords.first
        let second = todaysRecords.dropFirst().first
        let pastRecords = records.filter { $0.loggedAt < startOfToday }
        let plan = commonPlan(from: pastRecords)

        return CoachBehaviorContext(
            todaysRecordCount: todaysRecords.count,
            latestDrinkGrams: latest.map { Int($0.pureAlcoholGrams.rounded()) } ?? 0,
            minutesSinceLastDrink: latest.map { max(0, Int(now.timeIntervalSince($0.loggedAt) / 60)) },
            recentLogGapMinutes: latest.flatMap { latest in
                second.map { max(0, Int(latest.loggedAt.timeIntervalSince($0.loggedAt) / 60)) }
            },
            loggingStreakDays: loggingStreakDays(from: records, endingOn: now, calendar: calendar),
            plannedDrinkRawType: plan?.rawType,
            plannedDrinkCount: plan?.count ?? 1,
            plannedDrinkVolumeML: plan?.volumeML ?? 0,
            riskyWeekday: riskyWeekday(from: records, calendar: calendar, now: now),
            riskyTimeSlot: riskyTimeSlot(from: records, calendar: calendar, now: now)
        )
    }

    private func commonPlan(from records: [DrinkRecord]) -> (rawType: String, count: Int, volumeML: Int)? {
        let recent = records
            .sorted { $0.loggedAt > $1.loggedAt }
            .prefix(30)
        let grouped = Dictionary(grouping: recent) { record in
            "\(record.drinkType)|\(Int(record.volumeML.rounded()))"
        }
        guard let group = grouped.values.max(by: { $0.count < $1.count }),
              let sample = group.first else {
            return nil
        }
        let averageCount = group.reduce(0) { $0 + $1.numberOfDrinks } / max(group.count, 1)
        return (
            rawType: sample.drinkType,
            count: min(max(averageCount, 1), 3),
            volumeML: Int(sample.volumeML.rounded())
        )
    }

    private func loggingStreakDays(from records: [DrinkRecord], endingOn end: Date, calendar: Calendar) -> Int {
        var streak = 0
        var cursor = calendar.startOfDay(for: end)
        while true {
            let hasRecord = records.contains { calendar.isDate($0.loggedAt, inSameDayAs: cursor) }
            if hasRecord {
                streak += 1
            } else {
                break
            }
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = calendar.startOfDay(for: previous)
        }
        return streak
    }

    private func riskyWeekday(from records: [DrinkRecord], calendar: Calendar, now: Date) -> Int? {
        let currentWeekday = calendar.component(.weekday, from: now)
        let startOfToday = calendar.startOfDay(for: now)
        let dayBuckets = Dictionary(grouping: records.filter { $0.loggedAt < startOfToday }) {
            calendar.startOfDay(for: $0.loggedAt)
        }
        let matchingDays = dayBuckets.compactMap { day, dayRecords -> Double? in
            guard calendar.component(.weekday, from: day) == currentWeekday else { return nil }
            return dayRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
        }
        guard matchingDays.count >= 2 else { return nil }
        let average = matchingDays.reduce(0, +) / Double(matchingDays.count)
        return average >= dailyGoal * 0.8 ? currentWeekday : nil
    }

    private func riskyTimeSlot(from records: [DrinkRecord], calendar: Calendar, now: Date) -> String? {
        let currentHour = calendar.component(.hour, from: now)
        guard currentHour >= 21 else { return nil }
        let lateRecords = records.filter {
            $0.loggedAt < calendar.startOfDay(for: now)
                && calendar.component(.hour, from: $0.loggedAt) >= 21
        }
        guard lateRecords.count >= 3 else { return nil }
        let average = lateRecords.reduce(0) { $0 + $1.pureAlcoholGrams } / Double(lateRecords.count)
        return average >= dailyGoal * 0.4 ? "lateNight" : nil
    }
}
