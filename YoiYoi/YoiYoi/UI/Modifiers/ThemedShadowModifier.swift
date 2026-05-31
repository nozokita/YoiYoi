import SwiftUI

/// 影はニュートラルな奥行きを主役にし、テーマ色は薄い気配として添える。
struct ThemedShadowModifier: ViewModifier {
    let themeColor: Color
    let opacity: Double
    let radius: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: AppColors.darkBg.opacity(opacity * 0.42), radius: radius, x: 0, y: y)
            .shadow(color: themeColor.opacity(opacity * 0.32), radius: radius * 0.7, x: 0, y: y * 0.5)
    }
}

extension View {
    func themedShadow(themeColor: Color, opacity: Double, radius: CGFloat, y: CGFloat) -> some View {
        modifier(ThemedShadowModifier(themeColor: themeColor, opacity: opacity, radius: radius, y: y))
    }
}
