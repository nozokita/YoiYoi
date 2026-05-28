import Foundation
import SwiftData

@Model
final class DrinkRecord {
    @Attribute(.unique) var id: UUID = UUID()
    var drinkType: String
    var volumeML: Double
    var abvFraction: Double
    var pureAlcoholGrams: Double
    var numberOfDrinks: Int
    var loggedAt: Date
    var weekNumber: Int
    var yearNumber: Int
    var sessionID: UUID?

    /// - Parameters:
    ///   - loggedAt: `nil` のときは現在時刻（本番）。テストでは固定日時を渡す。
    ///   - calendar: 週番号・年の算出に使用（`loggedAt` と同一カレンダーにすること）。
    init(
        drinkType: String,
        volumeML: Double,
        abv: AlcoholByVolume,
        numberOfDrinks: Int,
        sessionID: UUID? = nil,
        loggedAt: Date? = nil,
        calendar: Calendar = .current
    ) {
        self.drinkType = drinkType
        self.volumeML = volumeML
        self.abvFraction = abv.fraction
        self.numberOfDrinks = numberOfDrinks
        self.pureAlcoholGrams = volumeML * abv.fraction * 0.8 * Double(numberOfDrinks)
        self.sessionID = sessionID
        let at = loggedAt ?? Date()
        self.loggedAt = at
        self.weekNumber = calendar.component(.weekOfYear, from: at)
        self.yearNumber = calendar.component(.yearForWeekOfYear, from: at)
    }

    func update(
        drinkType: String,
        volumeML: Double,
        abv: AlcoholByVolume,
        numberOfDrinks: Int
    ) {
        self.drinkType = drinkType
        self.volumeML = volumeML
        self.abvFraction = abv.fraction
        self.numberOfDrinks = numberOfDrinks
        self.pureAlcoholGrams = volumeML * abv.fraction * 0.8 * Double(numberOfDrinks)
    }
}
