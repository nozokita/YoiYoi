import SwiftUI

/// タップ中に `scaleEffect(0.95)`（DESIGN.md アニメーション表「ボタンタップスケール」）。
struct BounceOnTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BounceOnTapButtonStyle {
    static var bounceOnTap: BounceOnTapButtonStyle { BounceOnTapButtonStyle() }
}
