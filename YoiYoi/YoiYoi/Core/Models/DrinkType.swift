import Foundation

struct DrinkVolumeOption: Identifiable, Equatable, Sendable {
    let labelJA: String
    let labelEN: String
    let volumeML: Double

    var id: String { "\(labelEN)-\(Int(volumeML))" }

    func label(for language: SupportedLanguage) -> String {
        switch language {
        case .ja: "\(labelJA) \(Int(volumeML))ml"
        case .en: "\(labelEN) \(Int(volumeML))ml"
        }
    }
}

/// SPEC.md ドリンク初期データ。`rawValue` は SwiftData `DrinkRecord.drinkType` と一致。
enum DrinkType: String, CaseIterable, Codable, Sendable {
    case beer
    case wine
    case sake
    case whisky
    case cocktail
    case sour

    var icon: YoiYoiIcon {
        switch self {
        case .beer: return .drinkBeer
        case .wine: return .drinkWine
        case .sake: return .drinkSake
        case .whisky: return .drinkWhisky
        case .cocktail: return .drinkCocktail
        case .sour: return .drinkSour
        }
    }

    /// ホーム等の短い表示名（日本語）。
    var shortLabelJA: String {
        switch self {
        case .beer: return "ビール"
        case .wine: return "ワイン"
        case .sake: return "日本酒"
        case .whisky: return "ウイスキー"
        case .cocktail: return "カクテル"
        case .sour: return "サワー"
        }
    }

    var shortLabelEN: String {
        switch self {
        case .beer: return "Beer"
        case .wine: return "Wine"
        case .sake: return "Sake"
        case .whisky: return "Whisky"
        case .cocktail: return "Cocktail"
        case .sour: return "Sour"
        }
    }

    func shortLabel(for language: SupportedLanguage) -> String {
        switch language {
        case .ja: shortLabelJA
        case .en: shortLabelEN
        }
    }

    static func shortLabelJA(forRawType raw: String) -> String {
        DrinkType(rawValue: raw)?.shortLabelJA ?? raw
    }

    static func shortLabel(forRawType raw: String, language: SupportedLanguage) -> String {
        DrinkType(rawValue: raw)?.shortLabel(for: language) ?? raw
    }

    /// 1杯あたりの初期容量（ml）。
    var defaultVolumeML: Double {
        switch self {
        case .beer: return 350
        case .wine: return 125
        case .sake: return 180
        case .whisky: return 30
        case .cocktail: return 200
        case .sour: return 350
        }
    }

    var volumeOptions: [DrinkVolumeOption] {
        switch self {
        case .beer:
            [
                DrinkVolumeOption(labelJA: "小", labelEN: "Small draft", volumeML: 300),
                DrinkVolumeOption(labelJA: "生中", labelEN: "Medium draft", volumeML: 400),
                DrinkVolumeOption(labelJA: "缶", labelEN: "Can", volumeML: 350),
                DrinkVolumeOption(labelJA: "生大", labelEN: "Large draft", volumeML: 700),
            ]
        case .wine:
            [
                DrinkVolumeOption(labelJA: "少なめ", labelEN: "Small pour", volumeML: 100),
                DrinkVolumeOption(labelJA: "標準", labelEN: "Standard pour", volumeML: 125),
                DrinkVolumeOption(labelJA: "多め", labelEN: "Large pour", volumeML: 150),
            ]
        case .sake:
            [
                DrinkVolumeOption(labelJA: "半合", labelEN: "Half go", volumeML: 90),
                DrinkVolumeOption(labelJA: "1合", labelEN: "One go", volumeML: 180),
            ]
        case .whisky:
            [
                DrinkVolumeOption(labelJA: "シングル", labelEN: "Single", volumeML: 30),
                DrinkVolumeOption(labelJA: "ダブル", labelEN: "Double", volumeML: 60),
            ]
        case .cocktail:
            [
                DrinkVolumeOption(labelJA: "小さめ", labelEN: "Small", volumeML: 150),
                DrinkVolumeOption(labelJA: "標準", labelEN: "Standard", volumeML: 200),
                DrinkVolumeOption(labelJA: "大きめ", labelEN: "Large", volumeML: 300),
            ]
        case .sour:
            [
                DrinkVolumeOption(labelJA: "中", labelEN: "Medium", volumeML: 350),
                DrinkVolumeOption(labelJA: "大", labelEN: "Large", volumeML: 500),
                DrinkVolumeOption(labelJA: "メガ", labelEN: "Mega", volumeML: 700),
            ]
        }
    }

    /// 初期度数（内部は `fromFraction`）。
    var defaultAbv: AlcoholByVolume {
        switch self {
        case .beer: return .fromFraction(0.05)
        case .wine: return .fromFraction(0.12)
        case .sake: return .fromFraction(0.15)
        case .whisky: return .fromFraction(0.40)
        case .cocktail: return .fromFraction(0.05)
        case .sour: return .fromFraction(0.05)
        }
    }

    /// 1杯・既定容量・既定度数での純アルコール（g）。`volumeML * abv * 0.8`。
    var defaultPureAlcoholGrams: Double {
        defaultVolumeML * defaultAbv.fraction * 0.8
    }
}
