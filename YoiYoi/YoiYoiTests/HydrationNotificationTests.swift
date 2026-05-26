import Foundation
import Testing
@testable import YoiYoi

struct HydrationNotificationTests {
    @Test func createsTenReminderDatesAtConfiguredInterval() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = Date(timeIntervalSince1970: 0)
        let dates = NotificationService.hydrationReminderDates(
            startingAt: start,
            intervalMinutes: 30,
            calendar: calendar
        )

        #expect(dates.count == 10)
        #expect(abs((dates.first?.timeIntervalSince(start) ?? 0) - (30 * 60)) < 0.001)
        #expect(abs((dates.last?.timeIntervalSince(start) ?? 0) - (300 * 60)) < 0.001)
    }

    @Test func doesNotCreateDatesForInvalidInterval() {
        #expect(NotificationService.hydrationReminderDates(startingAt: Date(), intervalMinutes: 0).isEmpty)
    }

    @Test func capsCustomRequestCountAtMaximum() {
        let dates = NotificationService.hydrationReminderDates(
            startingAt: Date(timeIntervalSince1970: 0),
            intervalMinutes: 15,
            count: 99
        )
        #expect(dates.count == NotificationService.maximumHydrationReminders)
    }
}
