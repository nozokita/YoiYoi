import Foundation
import Observation

@Observable
@MainActor
final class DrinkLogViewModel {
    var selectedType: DrinkType?
    var numberOfDrinks: Int = 1
    /// ステッパー表示用（±0.5%）。保存時は `AlcoholByVolume.fromPercentage` 経由。
    var abvPercent: Double = 5

    var volumeML: Double {
        selectedType?.defaultVolumeML ?? 0
    }

    var abv: AlcoholByVolume {
        AlcoholByVolume.fromPercentage(abvPercent)
    }

    /// 純アルコール（g）— リアルタイム。
    var pureAlcoholGrams: Double {
        guard let type = selectedType else { return 0 }
        return type.defaultVolumeML * abv.fraction * 0.8 * Double(numberOfDrinks)
    }

    var canSave: Bool { selectedType != nil }

    func select(_ type: DrinkType) {
        selectedType = type
        abvPercent = type.defaultAbv.percentage
        numberOfDrinks = 1
    }

    func incrementDrinks() {
        numberOfDrinks = min(numberOfDrinks + 1, 99)
    }

    func decrementDrinks() {
        numberOfDrinks = max(numberOfDrinks - 1, 1)
    }

    func incrementAbv() {
        abvPercent = min(abvPercent + 0.5, 100)
    }

    func decrementAbv() {
        abvPercent = max(abvPercent - 0.5, 0)
    }
}
