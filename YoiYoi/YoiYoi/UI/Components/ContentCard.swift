import SwiftUI

/// DESIGN.md「コンテンツカード」— 上質な白背景 + 薄い境界線 + 控えめな影。
private struct ContentCardModifier: ViewModifier {
    let themeColor: Color

    func body(content: Content) -> some View {
        content
            .background(AppColors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(AppColors.hairline.opacity(0.85), lineWidth: 1)
            }
            .themedShadow(themeColor: themeColor, opacity: 0.10, radius: 18, y: 8)
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
