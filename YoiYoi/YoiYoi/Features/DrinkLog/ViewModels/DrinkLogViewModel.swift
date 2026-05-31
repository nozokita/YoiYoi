import Foundation
import Observation

@Observable
@MainActor
final class DrinkLogViewModel {
    var selectedType: DrinkType?
    var numberOfDrinks: Int = 1
    /// ステッパー表示用（±0.5%）。保存時は `AlcoholByVolume.fromPercentage` 経由。
    var abvPercent: Double = 5
    var volumeML: Double = 0

    var abv: AlcoholByVolume {
        AlcoholByVolume.fromPercentage(abvPercent)
    }

    /// 純アルコール（g）— リアルタイム。
    var pureAlcoholGrams: Double {
        guard selectedType != nil else { return 0 }
        return volumeML * abv.fraction * 0.8 * Double(numberOfDrinks)
    }

    var canSave: Bool { selectedType != nil }

    func select(_ type: DrinkType) {
        selectedType = type
        volumeML = type.defaultVolumeML
        abvPercent = type.defaultAbv.percentage
        numberOfDrinks = 1
    }

    func apply(drinkType: String, volumeML: Double, abvFraction: Double, numberOfDrinks: Int) {
        guard let type = DrinkType(rawValue: drinkType) else { return }
        selectedType = type
        self.volumeML = volumeML
        abvPercent = AlcoholByVolume.fromFraction(abvFraction).percentage
        self.numberOfDrinks = numberOfDrinks
    }

    func setVolume(_ ml: Double) {
        volumeML = ml.clamped(to: 10...2000)
    }

    func incrementVolume() {
        setVolume(volumeML + 10)
    }

    func decrementVolume() {
        setVolume(volumeML - 10)
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

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
