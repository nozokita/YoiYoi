import SwiftUI

/// 統計・ガイドライン用の横長カード。数字は `AppFonts.statCardValue()`（28pt Heavy）。
struct StatCard: View {
    let title: String
    let value: String
    let emoji: String
    let backgroundColor: Color
    var language: SupportedLanguage = .ja

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Text(emoji)
                .font(.system(size: 32))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFonts.body(for: language, size: 15))
                    .foregroundStyle(AppColors.charcoal)
                Text(value)
                    .font(AppFonts.statCardValue())
                    .foregroundStyle(AppColors.charcoal)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppSpacing.lg)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview("StatCard") {
    StatCard(
        title: "1日の目安",
        value: "40g",
        emoji: "📊",
        backgroundColor: AppColors.mintLight
    )
    .padding()
    .background(AppColors.cream)
}
