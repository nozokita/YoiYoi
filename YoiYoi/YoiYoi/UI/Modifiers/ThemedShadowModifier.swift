import SwiftUI

/// 影はテーマ色からのみ派生する（DESIGN.md「影ルール」）。
struct ThemedShadowModifier: ViewModifier {
    let themeColor: Color
    let opacity: Double
    let radius: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content.shadow(color: themeColor.opacity(opacity), radius: radius, x: 0, y: y)
    }
}

extension View {
    func themedShadow(themeColor: Color, opacity: Double, radius: CGFloat, y: CGFloat) -> some View {
        modifier(ThemedShadowModifier(themeColor: themeColor, opacity: opacity, radius: radius, y: y))
    }
}
