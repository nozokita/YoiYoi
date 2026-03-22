import SwiftUI

/// DESIGN.md タイポグラフィ + `SupportedLanguage.fontFamily` に沿った本文系の切り替え。
enum AppFonts {
    // MARK: - ヒーロー（SF Pro Rounded）

    static func heroTitle() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }

    static func heroSubtitle() -> Font {
        .system(size: 15, weight: .medium, design: .rounded)
    }

    // MARK: - 画面・カードタイトル（Rounded）

    static func screenTitle(for language: SupportedLanguage) -> Font {
        switch language {
        case .ja, .en:
            return .system(size: 24, weight: .bold, design: .rounded)
        }
    }

    static func cardTitle(for language: SupportedLanguage) -> Font {
        switch language {
        case .ja, .en:
            return .system(size: 18, weight: .bold, design: .rounded)
        }
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
