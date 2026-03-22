import Foundation

/// 純アルコール集計（日計・週計・目標に対する割合・ストリーク）。
enum AlcoholCalculator {
    /// 指定暦日の合計純アルコール（g）。`day` はその日の任意の時刻でよい（日内は正規化）。
    static func dailyTotal(gramsFrom records: [DrinkRecord], on day: Date, calendar: Calendar) -> Double {
        let start = calendar.startOfDay(for: day)
        return records
            .filter { calendar.isDate($0.loggedAt, inSameDayAs: start) }
            .reduce(0) { $0 + $1.pureAlcoholGrams }
    }

    /// `date` が属する ISO 週（`weekOfYear` + `yearForWeekOfYear`）の合計。
    static func weeklyTotal(gramsFrom records: [DrinkRecord], inWeekOf date: Date, calendar: Calendar) -> Double {
        let week = calendar.component(.weekOfYear, from: date)
        let year = calendar.component(.yearForWeekOfYear, from: date)
        return records
            .filter {
                calendar.component(.weekOfYear, from: $0.loggedAt) == week
                    && calendar.component(.yearForWeekOfYear, from: $0.loggedAt) == year
            }
            .reduce(0) { $0 + $1.pureAlcoholGrams }
    }

    /// 1日の目標までの残り（g）。超過時は 0。
    static func remainingToday(consumed: Double, dailyGoal: Double) -> Double {
        max(0, dailyGoal - consumed)
    }

    /// 消費量を目標に対する百分率で表す。`goal <= 0` のときは 0。
    static func percentage(consumed: Double, goal: Double) -> Double {
        guard goal > 0 else { return 0 }
        return (consumed / goal) * 100
    }

    /// 連続ストリーク日数（`endingOn` の暦日を含み、過去へ遡る）。
    /// 各日の合計が `dailyGoalGrams` 以下ならその日はストリークに含める（0g の休肝日も含む）。
    static func streakDays(
        gramsFrom records: [DrinkRecord],
        dailyGoalGrams: Double,
        endingOn end: Date,
        calendar: Calendar
    ) -> Int {
        var streak = 0
        var cursor = calendar.startOfDay(for: end)
        while true {
            let total = dailyTotal(gramsFrom: records, on: cursor, calendar: calendar)
            if total <= dailyGoalGrams {
                streak += 1
            } else {
                break
            }
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = calendar.startOfDay(for: previous)
        }
        return streak
    }

    /// 指定週（`date` が属する `weekOfYear`）の暦日のうち、純アルコール合計が 0g の日数。
    static func restDaysInWeek(gramsFrom records: [DrinkRecord], containing date: Date, calendar: Calendar) -> Int {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return 0 }
        var rest = 0
        var cursor = interval.start
        while cursor < interval.end {
            if dailyTotal(gramsFrom: records, on: cursor, calendar: calendar) == 0 {
                rest += 1
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = calendar.startOfDay(for: next)
        }
        return rest
    }
}
