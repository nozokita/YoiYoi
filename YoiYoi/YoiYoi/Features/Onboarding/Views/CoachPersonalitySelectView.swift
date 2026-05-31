import SwiftUI

struct CoachPersonalitySelectView: View {
    @Bindable var vm: OnboardingViewModel
    let language: SupportedLanguage
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                OnboardingBackButton(title: AppCopy.commonBack(language), action: onBack)

                OnboardingHeroHeader(
                    stepText: "3 / 3",
                    title: AppCopy.onboardingCoachTitle(language),
                    detail: AppCopy.onboardingCoachDetail(language),
                    language: language
                )

                ForEach(CoachPersonality.allCases) { personality in
                    personalityRow(personality)
                }

                PuffyButton(title: AppCopy.onboardingStart(language), isEnabled: true) {
                    onContinue()
                }
                .accessibilityIdentifier("onboarding.coach.start")
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.lg)
        }
    }

    private func personalityRow(_ personality: CoachPersonality) -> some View {
        let selected = vm.selectedPersonality == personality
        return Button {
            vm.selectedPersonality = personality
        } label: {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(selected ? AppColors.coralRed : AppColors.charcoal.opacity(0.08))
                    .frame(width: 4)
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(personality.displayName(language))
                        .font(AppFonts.cardTitle())
                        .foregroundStyle(AppColors.charcoal)
                    Text(personality.sampleMessage(language))
                        .font(AppFonts.body(for: language, size: 13))
                        .foregroundStyle(AppColors.greyText)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                OnboardingSelectionMark(isSelected: selected)
            }
            .padding(AppSpacing.lg)
            .background(selected ? AppColors.surfaceElevated : AppColors.surfaceElevated.opacity(0.76))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(selected ? AppColors.coralRed.opacity(0.85) : AppColors.hairline, lineWidth: selected ? 1.5 : 1)
            }
            .themedShadow(themeColor: selected ? AppColors.coralRed : AppColors.hairline, opacity: selected ? 0.10 : 0.05, radius: selected ? 16 : 10, y: selected ? 8 : 5)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CoachPersonalitySelectView(vm: OnboardingViewModel(), language: .ja, onBack: {}, onContinue: {})
        .background(AppGradients.onboardingFullScreen)
}
