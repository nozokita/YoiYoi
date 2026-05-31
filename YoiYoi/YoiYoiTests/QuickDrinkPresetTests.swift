import Foundation
import Testing
@testable import YoiYoi

struct QuickDrinkPresetTests {
    private static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private static func date(_ minute: Int) -> Date {
        utcCalendar.date(from: DateComponents(year: 2026, month: 5, day: 26, hour: 18, minute: minute))!
    }

    @Test func recentRecordsAreUniqueAndNewestFirst() {
        let oldBeer = QuickDrinkService.makeRecord(
            drinkType: "beer", volumeML: 350, abvFraction: 0.05, numberOfDrinks: 1,
            loggedAt: Self.date(1), calendar: Self.utcCalendar
        )
        let wine = QuickDrinkService.makeRecord(
            drinkType: "wine", volumeML: 125, abvFraction: 0.12, numberOfDrinks: 1,
            loggedAt: Self.date(2), calendar: Self.utcCalendar
        )
        let newBeer = QuickDrinkService.makeRecord(
            drinkType: "beer", volumeML: 350, abvFraction: 0.05, numberOfDrinks: 1,
            loggedAt: Self.date(3), calendar: Self.utcCalendar
        )

        let recent = QuickDrinkService.recentUnique(from: [oldBeer, wine, newBeer])

        #expect(recent.count == 2)
        #expect(recent[0].id == newBeer.id)
        #expect(recent[1].id == wine.id)
    }

    @Test func recentRecordsAreCappedAtFive() {
        let records = (0..<8).map { index in
            QuickDrinkService.makeRecord(
                drinkType: "beer", volumeML: Double(100 + index), abvFraction: 0.05,
                numberOfDrinks: 1, loggedAt: Self.date(index), calendar: Self.utcCalendar
            )
        }
        #expect(QuickDrinkService.recentUnique(from: records).count == 5)
        #expect(QuickDrinkPreset.maximumCount == 6)
    }

    @Test func quickRecordCarriesActiveSession() {
        let sessionID = UUID()
        let record = QuickDrinkService.makeRecord(
            drinkType: "sour", volumeML: 350, abvFraction: 0.05, numberOfDrinks: 2,
            sessionID: sessionID
        )
        #expect(record.sessionID == sessionID)
        #expect(record.pureAlcoholGrams == 28)
    }

    @MainActor
    @Test func homeRefreshReflectsRecordsInTodayTotalAndRecent() {
        let record = QuickDrinkService.makeRecord(
            drinkType: "beer",
            volumeML: 350,
            abvFraction: 0.05,
            numberOfDrinks: 1
        )
        let viewModel = HomeViewModel()

        viewModel.refresh(
            records: [record],
            profiles: [UserProfile()],
            presets: [],
            sessions: []
        )

        #expect(abs(viewModel.todayConsumed - record.pureAlcoholGrams) < 0.0001)
        #expect(viewModel.todaysDrinkRecords.map(\.id) == [record.id])
        #expect(viewModel.recentRecords.map(\.id) == [record.id])
    }
}
