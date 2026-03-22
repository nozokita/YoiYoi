import Foundation

/// 記録後の状態から `FeedPost` を組み立てる（Firestore 非依存）。
enum FeedGenerator {
    struct Context: Sendable {
        var referenceDate: Date
        var uid: String
        var language: String
        /// 当該日の純アルコール合計（g）
        var todayTotalGrams: Double
        var dailyGoalGrams: Double
        /// 当該 ISO 週の合計（g）
        var weeklyTotalGrams: Double
        var weeklyGoalGrams: Double
        var streakDays: Int
        /// 当日分のドリンク種別（杯数分だけ要素を重ねる）
        var drinkTypesToday: [String]
    }

    /// 優先度: `rest_day`（0g）→ `over_goal`（日次超過）→ `weekly_achieved`（週の最終日かつ週合計が週目標以内）→ `goal_met`。
    static func generatePost(context: Context, calendar: Calendar = .current) -> FeedPost {
        let today = context.todayTotalGrams
        let dailyGoal = context.dailyGoalGrams
        let weeklyGoal = context.weeklyGoalGrams
        let weekTot = context.weeklyTotalGrams

        let kind: FeedPost.Kind
        if today == 0 {
            kind = .restDay
        } else if dailyGoal > 0, today > dailyGoal {
            kind = .overGoal
        } else if weeklyGoal > 0, weekTot <= weeklyGoal, isLastDayOfWeek(for: context.referenceDate, calendar: calendar) {
            kind = .weeklyAchieved
        } else {
            kind = .goalMet
        }

        let (actual, goal, pct) = metrics(for: kind, context: context)

        return FeedPost(
            documentID: UUID().uuidString,
            uid: context.uid,
            type: kind,
            actualGrams: actual,
            goalGrams: goal,
            percentage: pct,
            drinks: context.drinkTypesToday,
            streakDays: context.streakDays,
            messageVariant: Int.random(in: 0 ..< 5),
            language: context.language,
            reactions: .zero,
            reactedUIDs: [],
            createdAt: Date()
        )
    }

    private static func metrics(for kind: FeedPost.Kind, context: Context) -> (Double, Double, Double) {
        switch kind {
        case .restDay:
            return (0, context.dailyGoalGrams, 0)
        case .goalMet:
            let g = max(context.dailyGoalGrams, 1)
            let p = AlcoholCalculator.percentage(consumed: context.todayTotalGrams, goal: g)
            return (context.todayTotalGrams, context.dailyGoalGrams, p)
        case .overGoal:
            let g = max(context.dailyGoalGrams, 1)
            let p = AlcoholCalculator.percentage(consumed: context.todayTotalGrams, goal: g)
            return (context.todayTotalGrams, context.dailyGoalGrams, p)
        case .weeklyAchieved:
            let g = max(context.weeklyGoalGrams, 1)
            let p = AlcoholCalculator.percentage(consumed: context.weeklyTotalGrams, goal: g)
            return (context.weeklyTotalGrams, context.weeklyGoalGrams, p)
        }
    }

    static func isLastDayOfWeek(for date: Date, calendar: Calendar) -> Bool {
        let start = calendar.startOfDay(for: date)
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: start),
              let intervalToday = calendar.dateInterval(of: .weekOfYear, for: start),
              let intervalTomorrow = calendar.dateInterval(of: .weekOfYear, for: tomorrow)
        else {
            return false
        }
        return intervalToday != intervalTomorrow
    }
}
