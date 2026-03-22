import Foundation
import Testing
@testable import YoiYoi

struct DrinkRecordTests {
    private static var utcCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }

    private static func noonUTC(year: Int, month: Int, day: Int) -> Date {
        utcCalendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    @Test(arguments: [
        (DrinkType.beer, 14.0),
        (DrinkType.wine, 12.0),
        (DrinkType.sake, 21.6),
        (DrinkType.whisky, 9.6),
        (DrinkType.cocktail, 8.0),
        (DrinkType.sour, 14.0)
    ])
    func defaultSingleDrinkPureAlcohol(type: DrinkType, expectedGrams: Double) {
        let record = DrinkRecord(
            drinkType: type.rawValue,
            volumeML: type.defaultVolumeML,
            abv: type.defaultAbv,
            numberOfDrinks: 1,
            loggedAt: Self.noonUTC(year: 2026, month: 6, day: 15),
            calendar: Self.utcCalendar
        )
        #expect(abs(record.pureAlcoholGrams - expectedGrams) < 0.0001)
        #expect(record.abvFraction == type.defaultAbv.fraction)
    }

    @Test func beerTwoDrinksDoublesGrams() {
        let type = DrinkType.beer
        let record = DrinkRecord(
            drinkType: type.rawValue,
            volumeML: type.defaultVolumeML,
            abv: type.defaultAbv,
            numberOfDrinks: 2,
            loggedAt: Self.noonUTC(year: 2026, month: 6, day: 15),
            calendar: Self.utcCalendar
        )
        #expect(abs(record.pureAlcoholGrams - 28.0) < 0.0001)
    }

    @Test func customVolumeMatchesFormula() {
        let abv = AlcoholByVolume.fromPercentage(5)
        let record = DrinkRecord(
            drinkType: DrinkType.beer.rawValue,
            volumeML: 500,
            abv: abv,
            numberOfDrinks: 1,
            loggedAt: Self.noonUTC(year: 2026, month: 6, day: 15),
            calendar: Self.utcCalendar
        )
        // 500 * 0.05 * 0.8 = 20
        #expect(abs(record.pureAlcoholGrams - 20.0) < 0.0001)
    }
}
