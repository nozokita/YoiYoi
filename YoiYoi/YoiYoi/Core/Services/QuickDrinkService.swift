import Foundation

enum QuickDrinkService {
    static let recentLimit = 5

    static func recentUnique(from records: [DrinkRecord], limit: Int = recentLimit) -> [DrinkRecord] {
        var seen = Set<DrinkSignature>()
        return records
            .sorted { $0.loggedAt > $1.loggedAt }
            .filter { seen.insert(DrinkSignature(record: $0)).inserted }
            .prefix(limit)
            .map { $0 }
    }

    static func makeRecord(
        drinkType: String,
        volumeML: Double,
        abvFraction: Double,
        numberOfDrinks: Int,
        sessionID: UUID? = nil,
        loggedAt: Date? = nil,
        calendar: Calendar = .current
    ) -> DrinkRecord {
        DrinkRecord(
            drinkType: drinkType,
            volumeML: volumeML,
            abv: .fromFraction(abvFraction),
            numberOfDrinks: numberOfDrinks,
            sessionID: sessionID,
            loggedAt: loggedAt,
            calendar: calendar
        )
    }

    private struct DrinkSignature: Hashable {
        let drinkType: String
        let volumeML: Double
        let abvFraction: Double
        let numberOfDrinks: Int

        init(record: DrinkRecord) {
            drinkType = record.drinkType
            volumeML = record.volumeML
            abvFraction = record.abvFraction
            numberOfDrinks = record.numberOfDrinks
        }
    }
}
