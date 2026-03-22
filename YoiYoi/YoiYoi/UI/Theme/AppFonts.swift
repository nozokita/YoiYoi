import SwiftUI

/// DESIGN.md タイポグラフィに準拠。
///
/// `SupportedLanguage.fontFamily` は UI 以外（例: 将来の NSAttributedString 生成）用に残置。
/// SwiftUI のフォント API は `.system(design:)` で Rounded / Default を切り替えるのが正式のため、
/// ここでは `fontFamily` 文字列ではなくシステム API を使用している。
enum AppFonts {
    // MARK: - ヒーロー（SF Pro Rounded）

    static func heroTitle() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }

    static func heroSubtitle() -> Font {
        .system(size: 15, weight: .medium, design: .rounded)
    }

    // MARK: - 画面・カードタイトル（Rounded — DESIGN: 全言語共通）

    static func screenTitle() -> Font {
        .system(size: 24, weight: .bold, design: .rounded)
    }

    static func cardTitle() -> Font {
        .system(size: 18, weight: .bold, design: .rounded)
    }

    /// 本文: JA はシステム（ヒラギノ系）、EN は Rounded。
    static func body(for language: SupportedLanguage, size: CGFloat = 16) -> Font {
        switch language {
        case .ja:
            return .system(size: size, weight: .medium, design: .default)
        case .en:
            return .system(size: size, weight: .medium, design: .rounded)
        }
    }

    /// メーター数字（48pt Heavy Rounded）。
    static func meterNumber() -> Font {
        .system(size: 48, weight: .heavy, design: .rounded)
    }

    /// StatCard・ガイドライン数値など（28pt Heavy Rounded、DESIGN.md 性別・目標画面）。
    static func statCardValue() -> Font {
        .system(size: 28, weight: .heavy, design: .rounded)
    }

    static func sublabel(for language: SupportedLanguage, size: CGFloat = 13) -> Font {
        switch language {
        case .ja:
            return .system(size: size, weight: .regular, design: .default)
        case .en:
            return .system(size: size, weight: .regular, design: .rounded)
        }
    }

    static func buttonLabel() -> Font {
        .system(size: 17, weight: .bold, design: .rounded)
    }
}
