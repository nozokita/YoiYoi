import Foundation
import Testing
@testable import YoiYoi

struct SessionManagerTests {
    @Test func findsNewestActiveSession() {
        let older = DrinkingSession(startTime: Date(timeIntervalSince1970: 100))
        let newer = DrinkingSession(startTime: Date(timeIntervalSince1970: 200))
        let closed = DrinkingSession(startTime: Date(timeIntervalSince1970: 300))
        closed.endTime = Date(timeIntervalSince1970: 400)

        #expect(SessionManager.activeSession(in: [older, closed, newer])?.id == newer.id)
    }

    @Test func sessionTotalOnlyIncludesLinkedRecords() {
        let session = DrinkingSession()
        let linked = QuickDrinkService.makeRecord(
            drinkType: "beer", volumeML: 350, abvFraction: 0.05, numberOfDrinks: 1,
            sessionID: session.id
        )
        let outside = QuickDrinkService.makeRecord(
            drinkType: "beer", volumeML: 350, abvFraction: 0.05, numberOfDrinks: 1
        )

        #expect(SessionManager.records(for: session.id, in: [linked, outside]).count == 1)
        #expect(SessionManager.pureAlcoholTotal(for: session.id, in: [linked, outside]) == 14)
    }

    @Test func elapsedTimeFormatsHoursMinutesSeconds() {
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 5535)
        #expect(SessionManager.elapsedText(from: start, to: end) == "01:32:15")
    }
}
