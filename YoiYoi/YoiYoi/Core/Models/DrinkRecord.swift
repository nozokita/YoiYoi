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

    init(drinkType: String, volumeML: Double, abv: AlcoholByVolume, numberOfDrinks: Int) {
        self.drinkType = drinkType
        self.volumeML = volumeML
        self.abvFraction = abv.fraction
        self.numberOfDrinks = numberOfDrinks
        self.pureAlcoholGrams = volumeML * abv.fraction * 0.8 * Double(numberOfDrinks)
        let now = Date()
        self.loggedAt = now
        let cal = Calendar.current
        self.weekNumber = cal.component(.weekOfYear, from: now)
        // ISO 週番号と整合する年（年末が翌週第1週に入るケースで .year とずれないようにする）
        self.yearNumber = cal.component(.yearForWeekOfYear, from: now)
    }
}
