import SwiftUI

/// DESIGN.md「② グラデーションアクセントカード」— 高さ 72pt、左テキスト + 右 SVG アイコン。
struct GradientAccentCard: View {
    let title: String
    var subtitle: String?
    let icon: YoiYoiIcon
    let gradientColors: [Color]

    private var shadowColor: Color {
        gradientColors.last ?? AppColors.coralRed
    }

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFonts.cardTitle())
                    .foregroundStyle(AppColors.pureWhite)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppFonts.heroSubtitle())
                        .foregroundStyle(AppColors.pureWhite.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SVGIcon(icon: icon, size: 32, color: AppColors.pureWhite)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .frame(minHeight: 72, alignment: .center)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .themedShadow(themeColor: shadowColor, opacity: 0.20, radius: 12, y: 4)
    }
}

#Preview("GradientAccentCard") {
    GradientAccentCard(
        title: "今日の記録",
        subtitle: "あと 12g",
        icon: .drinkBeer,
        gradientColors: [AppColors.coralLight, AppColors.coralRed]
    )
    .padding()
    .background(AppColors.cream)
}
