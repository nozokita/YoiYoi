import UIKit

/// ウェーブヒーローの高さ。`GeometryReader` は親から高さ 0 が渡ると `ScrollView` ごと潰れるため、
/// メイン画面領域では **画面の高さベース**で決める（DESIGN.md の「画面の約35%」に相当）。
enum WaveHeroLayout {
    static func heroHeight(screenHeight: CGFloat? = nil, fraction: CGFloat = 0.35, minimum: CGFloat = 260) -> CGFloat {
        let h = screenHeight ?? UIScreen.main.bounds.height
        return max(h * fraction, minimum)
    }
}
