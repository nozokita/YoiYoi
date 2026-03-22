import SwiftUI

/// Pill バッジ（DESIGN.md: cornerRadius 999）。
struct PillTag: View {
    let text: String
    let bgColor: Color
    let textColor: Color
    let isSelected: Bool

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(textColor)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(bgColor)
            .clipShape(Capsule())
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("PillTag") {
    HStack(spacing: AppSpacing.sm) {
        PillTag(text: "ほろよい", bgColor: AppColors.coralRed, textColor: AppColors.pureWhite, isSelected: true)
        PillTag(text: "のんびり", bgColor: AppColors.pureWhite, textColor: AppColors.charcoal, isSelected: false)
    }
    .padding()
    .background(AppColors.cream)
}
