import Foundation
import Testing
@testable import YoiYoi

struct FeedGeneratorTests {
    private static var utc: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        cal.firstWeekday = 2
        return cal
    }

    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        Self.utc.date(from: DateComponents(year: y, month: m, day: d, hour: 12))!
    }

    @Test func restDayWhenTodayZero() {
        let ctx = FeedGenerator.Context(
            referenceDate: Self.date(2026, 6, 15),
            uid: "u",
            language: "ja",
            todayTotalGrams: 0,
            dailyGoalGrams: 40,
            weeklyTotalGrams: 0,
            weeklyGoalGrams: 280,
            streakDays: 3,
            drinkTypesToday: []
        )
        let post = FeedGenerator.generatePost(context: ctx, calendar: Self.utc)
        #expect(post.type == FeedPost.Kind.restDay)
    }

    @Test func overGoalWhenExceedsDaily() {
        let ctx = FeedGenerator.Context(
            referenceDate: Self.date(2026, 6, 15),
            uid: "u",
            language: "ja",
            todayTotalGrams: 50,
            dailyGoalGrams: 40,
            weeklyTotalGrams: 50,
            weeklyGoalGrams: 280,
            streakDays: 0,
            drinkTypesToday: ["beer"]
        )
        let post = FeedGenerator.generatePost(context: ctx, calendar: Self.utc)
        #expect(post.type == FeedPost.Kind.overGoal)
        #expect(post.actualGrams == 50)
    }

    @Test func goalMetWhenUnderDailyAndNotLastDayOfWeek() {
        // 2026-06-15 is Monday — not last day of ISO week
        let ctx = FeedGenerator.Context(
            referenceDate: Self.date(2026, 6, 15),
            uid: "u",
            language: "ja",
            todayTotalGrams: 20,
            dailyGoalGrams: 40,
            weeklyTotalGrams: 20,
            weeklyGoalGrams: 280,
            streakDays: 1,
            drinkTypesToday: ["beer", "beer"]
        )
        let post = FeedGenerator.generatePost(context: ctx, calendar: Self.utc)
        #expect(post.type == FeedPost.Kind.goalMet)
        #expect(post.drinks.count == 2)
    }

    @Test func weeklyAchievedOnLastDayOfWeekWhenWeekUnderGoal() {
        // 2026-06-21 is Sunday (UTC) — last day of week starting Monday 15th
        let ctx = FeedGenerator.Context(
            referenceDate: Self.date(2026, 6, 21),
            uid: "u",
            language: "ja",
            todayTotalGrams: 10,
            dailyGoalGrams: 40,
            weeklyTotalGrams: 80,
            weeklyGoalGrams: 280,
            streakDays: 5,
            drinkTypesToday: ["wine"]
        )
        let post = FeedGenerator.generatePost(context: ctx, calendar: Self.utc)
        #expect(post.type == FeedPost.Kind.weeklyAchieved)
        #expect(post.goalGrams == 280)
    }

    @Test func overGoalTakesPriorityOverWeeklyAchieved() {
        let ctx = FeedGenerator.Context(
            referenceDate: Self.date(2026, 6, 21),
            uid: "u",
            language: "ja",
            todayTotalGrams: 100,
            dailyGoalGrams: 40,
            weeklyTotalGrams: 100,
            weeklyGoalGrams: 280,
            streakDays: 0,
            drinkTypesToday: ["beer"]
        )
        let post = FeedGenerator.generatePost(context: ctx, calendar: Self.utc)
        #expect(post.type == FeedPost.Kind.overGoal)
    }

    @Test func isLastDayOfWeekDetection() {
        let mon = Self.date(2026, 6, 15)
        let sun = Self.date(2026, 6, 21)
        #expect(FeedGenerator.isLastDayOfWeek(for: mon, calendar: Self.utc) == false)
        #expect(FeedGenerator.isLastDayOfWeek(for: sun, calendar: Self.utc) == true)
    }
}
