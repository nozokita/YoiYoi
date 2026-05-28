import SwiftUI

struct OnboardingHeroHeader: View {
    let stepText: String
    let title: String
    var detail: String? = nil
    let language: SupportedLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(stepText)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.coralRed)
                .tracking(1.1)
                .textCase(.uppercase)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.surfaceElevated.opacity(0.88))
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(AppColors.hairline, lineWidth: 1)
                }

            Text(title)
                .font(AppFonts.heroTitle())
                .foregroundStyle(AppColors.charcoal)
                .fixedSize(horizontal: false, vertical: true)

            if let detail, !detail.isEmpty {
                Text(detail)
                    .font(AppFonts.body(for: language, size: 15))
                    .foregroundStyle(AppColors.greyText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OnboardingBackButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.charcoal)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.surfaceElevated.opacity(0.88))
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(AppColors.hairline, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingSelectionMark: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? AppColors.coralRed : AppColors.charcoal.opacity(0.14), lineWidth: 1.4)
                .background(
                    Circle()
                        .fill(isSelected ? AppColors.coralRed : Color.clear)
                )
            if isSelected {
                Circle()
                    .fill(AppColors.pureWhite)
                    .frame(width: 7, height: 7)
            }
        }
        .frame(width: 22, height: 22)
        .accessibilityHidden(true)
    }
}
