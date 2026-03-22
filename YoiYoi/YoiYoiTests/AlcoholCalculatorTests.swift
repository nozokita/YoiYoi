import Foundation
import Testing
@testable import YoiYoi

struct AlcoholCalculatorTests {
    private static var utcCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }

    private static func noonUTC(year: Int, month: Int, day: Int) -> Date {
        utcCalendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    @Test func dailyTotalEmpty() {
        let total = AlcoholCalculator.dailyTotal(
            gramsFrom: [],
            on: Self.noonUTC(year: 2026, month: 6, day: 1),
            calendar: Self.utcCalendar
        )
        #expect(total == 0)
    }

    @Test func dailyTotalSumsRecordsOnSameDay() {
        let day = Self.noonUTC(year: 2026, month: 6, day: 10)
        let r1 = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 350,
            abv: .fromFraction(0.05),
            numberOfDrinks: 1,
            loggedAt: day,
            calendar: Self.utcCalendar
        )
        let r2 = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 350,
            abv: .fromFraction(0.05),
            numberOfDrinks: 1,
            loggedAt: Self.utcCalendar.date(byAdding: .hour, value: 3, to: day)!,
            calendar: Self.utcCalendar
        )
        let total = AlcoholCalculator.dailyTotal(gramsFrom: [r1, r2], on: day, calendar: Self.utcCalendar)
        #expect(abs(total - 28.0) < 0.0001)
    }

    @Test func dailyTotalIgnoresOtherDays() {
        let dayA = Self.noonUTC(year: 2026, month: 6, day: 5)
        let dayB = Self.noonUTC(year: 2026, month: 6, day: 6)
        let rA = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 350,
            abv: .fromFraction(0.05),
            numberOfDrinks: 1,
            loggedAt: dayA,
            calendar: Self.utcCalendar
        )
        let rB = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 350,
            abv: .fromFraction(0.05),
            numberOfDrinks: 1,
            loggedAt: dayB,
            calendar: Self.utcCalendar
        )
        let total = AlcoholCalculator.dailyTotal(gramsFrom: [rA, rB], on: dayA, calendar: Self.utcCalendar)
        #expect(abs(total - 14.0) < 0.0001)
    }

    @Test func weeklyTotalOnlyCountsSameISOWeek() {
        let inWeek = Self.noonUTC(year: 2026, month: 6, day: 10)
        let nextWeek = Self.noonUTC(year: 2026, month: 6, day: 17)
        let rIn = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 350,
            abv: .fromFraction(0.05),
            numberOfDrinks: 1,
            loggedAt: inWeek,
            calendar: Self.utcCalendar
        )
        let rOut = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 350,
            abv: .fromFraction(0.05),
            numberOfDrinks: 1,
            loggedAt: nextWeek,
            calendar: Self.utcCalendar
        )
        let sum = AlcoholCalculator.weeklyTotal(
            gramsFrom: [rIn, rOut],
            inWeekOf: inWeek,
            calendar: Self.utcCalendar
        )
        #expect(abs(sum - 14.0) < 0.0001)
    }

    @Test func remainingTodayClampsAtZeroWhenOverGoal() {
        #expect(AlcoholCalculator.remainingToday(consumed: 10, dailyGoal: 40) == 30)
        #expect(AlcoholCalculator.remainingToday(consumed: 50, dailyGoal: 40) == 0)
    }

    @Test func percentageIsZeroWhenGoalNotPositive() {
        #expect(AlcoholCalculator.percentage(consumed: 10, goal: 0) == 0)
        #expect(AlcoholCalculator.percentage(consumed: 10, goal: -5) == 0)
    }

    @Test func percentageConsumedOverGoal() {
        #expect(AlcoholCalculator.percentage(consumed: 20, goal: 40) == 50)
        #expect(AlcoholCalculator.percentage(consumed: 60, goal: 40) == 150)
    }

    @Test func streakStopsWhenPriorDayExceedsGoal() {
        let cal = Self.utcCalendar
        let dayEnd = Self.noonUTC(year: 2026, month: 1, day: 10)
        let dayPrev = Self.noonUTC(year: 2026, month: 1, day: 9)
        let dayBreak = Self.noonUTC(year: 2026, month: 1, day: 8)
        let goal = 40.0
        // Jan 10: 10g OK, Jan 9: 20g OK, Jan 8: 50g NG → streak 2
        let rEnd = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 350,
            abv: .fromFraction(0.05),
            numberOfDrinks: 1,
            loggedAt: dayEnd,
            calendar: cal
        )
        let rPrev = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 350,
            abv: .fromFraction(0.05),
            numberOfDrinks: 1,
            loggedAt: dayPrev,
            calendar: cal
        )
        let rBreak = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 350,
            abv: .fromFraction(0.05),
            numberOfDrinks: 3,
            loggedAt: dayBreak,
            calendar: cal
        )
        let streak = AlcoholCalculator.streakDays(
            gramsFrom: [rEnd, rPrev, rBreak],
            dailyGoalGrams: goal,
            endingOn: dayEnd,
            calendar: cal
        )
        #expect(streak == 2)
    }
}
