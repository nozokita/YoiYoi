import Foundation
import Observation
import SwiftData

/// カレンダー 1 マスの表示状態（DESIGN.md 4 パターン + 未来日）。
enum CalendarDayVisualState: Equatable {
    /// 未来、または当日でまだ 0g
    case empty
    /// 過去日で 0g（休肝日スタイル）
    case restDay
    case underGoal
    case overGoal
}

struct CalendarDayCellData: Equatable {
    var isPlaceholder: Bool
    var date: Date?
    var dayNumber: Int
    var visual: CalendarDayVisualState
    var isToday: Bool
    var achievedLastOrder: Bool

    static let placeholder = CalendarDayCellData(
        isPlaceholder: true,
        date: nil,
        dayNumber: 0,
        visual: .empty,
        isToday: false,
        achievedLastOrder: false
    )
}

@Observable
@MainActor
final class CalendarViewModel {
    private(set) var calendar: Calendar
    var visibleMonth: Date

    init() {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        cal.locale = Locale(identifier: "ja_JP")
        calendar = cal
        visibleMonth = Date()
    }

    func startOfMonth(containing date: Date) -> Date {
        let c = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: c) ?? date
    }

    func shiftMonth(by delta: Int) {
        if let d = calendar.date(byAdding: .month, value: delta, to: visibleMonth) {
            visibleMonth = d
        }
    }

    /// 月グリッド用セル（先頭パディング + 各日）。
    func monthCells(
        records: [DrinkRecord],
        sessions: [DrinkingSession] = [],
        dailyGoal: Double,
        trackingStartDate: Date? = nil,
        today: Date = Date()
    ) -> [CalendarDayCellData] {
        let monthStart = startOfMonth(containing: visibleMonth)
        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }

        let weekday = calendar.component(.weekday, from: monthStart)
        let leading = (weekday + 5) % 7

        var cells: [CalendarDayCellData] = Array(repeating: .placeholder, count: leading)

        let startToday = calendar.startOfDay(for: today)
        let trackingStart = trackingStartDate.map { calendar.startOfDay(for: $0) }

        for day in dayRange {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let total = AlcoholCalculator.dailyTotal(gramsFrom: records, on: date, calendar: calendar)
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let achievedLastOrder = sessions.contains {
                $0.preventedLastOrder && calendar.isDate($0.startTime, inSameDayAs: date)
            }

            let visual: CalendarDayVisualState
            if dayStart > startToday || trackingStart.map({ dayStart < $0 }) == true {
                visual = .empty
            } else if total == 0 {
                visual = isToday ? .empty : .restDay
            } else if dailyGoal > 0, total > dailyGoal {
                visual = .overGoal
            } else {
                visual = .underGoal
            }

            cells.append(
                CalendarDayCellData(
                    isPlaceholder: false,
                    date: date,
                    dayNumber: day,
                    visual: visual,
                    isToday: isToday,
                    achievedLastOrder: achievedLastOrder
                )
            )
        }
        return cells
    }

    /// ヒーロー用: 表示中の月の集計（今日より未来の日は除外）。
    func monthSummaryCounts(
        records: [DrinkRecord],
        dailyGoal: Double,
        trackingStartDate: Date? = nil,
        today: Date = Date()
    ) -> (rest: Int, inGoal: Int, over: Int) {
        let monthStart = startOfMonth(containing: visibleMonth)
        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else { return (0, 0, 0) }
        let startToday = calendar.startOfDay(for: today)
        let trackingStart = trackingStartDate.map { calendar.startOfDay(for: $0) }
        var rest = 0
        var ok = 0
        var over = 0
        for day in dayRange {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            if dayStart > startToday { continue }
            if trackingStart.map({ dayStart < $0 }) == true { continue }
            let total = AlcoholCalculator.dailyTotal(gramsFrom: records, on: date, calendar: calendar)
            if total == 0 {
                if !calendar.isDate(date, inSameDayAs: today) {
                    rest += 1
                }
            } else if dailyGoal > 0, total > dailyGoal {
                over += 1
            } else {
                ok += 1
            }
        }
        return (rest, ok, over)
    }

    /// 今週（`reference` の属する週）の棒グラフ用データ。月曜始まり 7 本。
    func weekBarData(
        records: [DrinkRecord],
        dailyGoal: Double,
        reference: Date = Date(),
        language: SupportedLanguage
    ) -> [(label: String, grams: Double, over: Bool)] {
        let labels = AppCopy.weekdayInitials(language)
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: reference) else { return [] }
        var out: [(String, Double, Bool)] = []
        var d = interval.start
        for i in 0 ..< 7 {
            let g = AlcoholCalculator.dailyTotal(gramsFrom: records, on: d, calendar: calendar)
            let over = dailyGoal > 0 && g > dailyGoal
            out.append((labels[i], g, over))
            guard let next = calendar.date(byAdding: .day, value: 1, to: d) else { break }
            d = calendar.startOfDay(for: next)
        }
        return out
    }

    func monthTitleString(for date: Date, language: SupportedLanguage) -> String {
        switch language {
        case .ja:
            let y = calendar.component(.year, from: date)
            let m = calendar.component(.month, from: date)
            return "\(y)年\(m)月"
        case .en:
            let monthStart = startOfMonth(containing: date)
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US")
            f.dateFormat = "MMMM yyyy"
            return f.string(from: monthStart)
        }
    }
}
