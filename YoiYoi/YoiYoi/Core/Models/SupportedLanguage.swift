import Foundation

/// MVP: ja / en。言語追加はケース + ローカライズ文字列 + AppFonts で拡張する。
enum SupportedLanguage: String, CaseIterable, Codable, Identifiable, Sendable {
    case ja = "ja"
    case en = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ja: return "日本語"
        case .en: return "English"
        }
    }

    var flag: String {
        switch self {
        case .ja: return "🇯🇵"
        case .en: return "🇺🇸"
        }
    }

    var fontFamily: String {
        switch self {
        case .ja: return "Hiragino Sans"
        case .en: return ".SFProRounded"
        }
    }
}
