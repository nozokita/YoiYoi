import Foundation
import SwiftData

@Model
final class QuickDrinkPreset {
    static let maximumCount = 6

    @Attribute(.unique) var id: UUID = UUID()
    var displayName: String
    var drinkType: String
    var volumeML: Double
    var abvFraction: Double
    var numberOfDrinks: Int
    var sortOrder: Int
    var createdAt: Date

    init(
        displayName: String,
        drinkType: String,
        volumeML: Double,
        abvFraction: Double,
        numberOfDrinks: Int,
        sortOrder: Int = 0,
        createdAt: Date = Date()
    ) {
        self.displayName = displayName
        self.drinkType = drinkType
        self.volumeML = volumeML
        self.abvFraction = abvFraction
        self.numberOfDrinks = numberOfDrinks
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }

    func matches(_ record: DrinkRecord) -> Bool {
        drinkType == record.drinkType
            && volumeML == record.volumeML
            && abvFraction == record.abvFraction
            && numberOfDrinks == record.numberOfDrinks
    }
}
