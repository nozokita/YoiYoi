import Foundation

/// SPEC.md ドリンク初期データ。`rawValue` は SwiftData `DrinkRecord.drinkType` と一致。
enum DrinkType: String, CaseIterable, Codable, Sendable {
    case beer
    case wine
    case sake
    case whisky
    case cocktail
    case sour

    var emoji: String {
        switch self {
        case .beer: return "🍺"
        case .wine: return "🍷"
        case .sake: return "🍶"
        case .whisky: return "🥃"
        case .cocktail: return "🍸"
        case .sour: return "🍹"
        }
    }

    /// ホーム等の短い表示名（MVP は日本語固定。将来は言語連動）。
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

    static func shortLabelJA(forRawType raw: String) -> String {
        DrinkType(rawValue: raw)?.shortLabelJA ?? raw
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
