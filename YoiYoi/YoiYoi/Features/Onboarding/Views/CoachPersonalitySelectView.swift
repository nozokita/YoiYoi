import SwiftUI

struct CoachPersonalitySelectView: View {
    @Bindable var vm: OnboardingViewModel
    let language: SupportedLanguage
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Button(AppCopy.commonBack(language), action: onBack)
                    .font(AppFonts.body(for: language, size: 16))
                    .foregroundStyle(AppColors.coralRed)

                Text("💬")
                    .font(.system(size: 48))
                    .frame(maxWidth: .infinity)

                Text(AppCopy.onboardingCoachTitle(language))
                    .font(AppFonts.screenTitle())
                    .foregroundStyle(AppColors.charcoal)
                    .frame(maxWidth: .infinity)

                Text(AppCopy.onboardingCoachDetail(language))
                    .font(AppFonts.body(for: language, size: 15))
                    .foregroundStyle(AppColors.greyText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                ForEach(CoachPersonality.allCases) { personality in
                    personalityRow(personality)
                }

                PuffyButton(title: AppCopy.onboardingStart(language), isEnabled: true) {
                    onContinue()
                }
                .accessibilityIdentifier("onboarding.coach.start")
            }
            .padding(AppSpacing.lg)
        }
    }

    private func personalityRow(_ personality: CoachPersonality) -> some View {
        let selected = vm.selectedPersonality == personality
        return Button {
            vm.selectedPersonality = personality
        } label: {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                Text(personality.emoji)
                    .font(.system(size: 28))
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(personality.displayName(language))
                        .font(AppFonts.cardTitle())
                    Text(personality.sampleMessage(language))
                        .font(AppFonts.body(for: language, size: 13))
                        .foregroundStyle(AppColors.greyText)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? AppColors.coralRed : AppColors.greyText.opacity(0.4))
            }
            .foregroundStyle(AppColors.charcoal)
            .padding(AppSpacing.md)
            .background(selected ? AppColors.coralLight : AppColors.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? AppColors.coralRed : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CoachPersonalitySelectView(vm: OnboardingViewModel(), language: .ja, onBack: {}, onContinue: {})
        .background(AppGradients.onboardingFullScreen)
}
