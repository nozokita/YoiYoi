import Foundation

/// UI では 0–100% 表示、内部は 0.0–1.0 の小数。100 倍ズレを型で防ぐ。
struct AlcoholByVolume: Codable, Hashable, Sendable {
    let fraction: Double

    var percentage: Double { fraction * 100 }

    static func fromPercentage(_ percent: Double) -> AlcoholByVolume {
        precondition(percent >= 0 && percent <= 100, "ABV must be 0-100%")
        return AlcoholByVolume(fraction: percent / 100)
    }

    static func fromFraction(_ value: Double) -> AlcoholByVolume {
        precondition(value >= 0 && value <= 1.0, "ABV fraction must be 0.0-1.0")
        return AlcoholByVolume(fraction: value)
    }
}
