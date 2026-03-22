import SwiftUI

/// DESIGN.md「① コンテンツカード」— 白背景 + テーマ色シャドウ（radius 24）。
private struct ContentCardModifier: ViewModifier {
    let themeColor: Color

    func body(content: Content) -> some View {
        content
            .background(AppColors.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .themedShadow(themeColor: themeColor, opacity: 0.10, radius: 16, y: 6)
    }
}

extension View {
    func contentCard(themeColor: Color) -> some View {
        modifier(ContentCardModifier(themeColor: themeColor))
    }
}

#Preview("ContentCard modifier") {
    Text("プレビュー")
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.lg)
        .contentCard(themeColor: AppColors.coralRed)
        .padding()
        .background(AppColors.cream)
}
