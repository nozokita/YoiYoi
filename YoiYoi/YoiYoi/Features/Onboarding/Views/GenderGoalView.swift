import SwiftUI

/// DESIGN.md「オンボーディング: 性別・目標画面」
struct GenderGoalView: View {
    @Bindable var vm: OnboardingViewModel
    var language: SupportedLanguage
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                OnboardingBackButton(title: AppCopy.commonBack(language), action: onBack)

                OnboardingHeroHeader(
                    stepText: "2 / 3",
                    title: AppCopy.onboardingGoalTitle(language),
                    detail: AppCopy.onboardingGenderAutoHint(language),
                    language: language
                )

                Text(AppCopy.onboardingGenderLabel(language))
                    .font(AppFonts.sublabel(for: language, size: 13))
                    .foregroundStyle(AppColors.greyText)
                    .textCase(.uppercase)
                    .tracking(0.8)

                HStack(spacing: AppSpacing.sm) {
                    genderPill(.male, title: AppCopy.onboardingGenderMale(language))
                    genderPill(.female, title: AppCopy.onboardingGenderFemale(language))
                    genderPill(.custom, title: AppCopy.onboardingGenderCustom(language))
                }

                guidelineCard

                if vm.selectedGender == .custom {
                    stepperRow(
                        title: AppCopy.onboardingCustomDailyStepper(language),
                        value: Int(vm.dailyGoal),
                        decrement: { vm.adjustDailyGoal(by: -5) },
                        increment: { vm.adjustDailyGoal(by: 5) }
                    )
                    stepperRow(
                        title: AppCopy.onboardingCustomWeeklyStepper(language),
                        value: Int(vm.weeklyGoal),
                        decrement: { vm.adjustWeeklyGoal(by: -35) },
                        increment: { vm.adjustWeeklyGoal(by: 35) }
                    )
                }

                PuffyButton(title: AppCopy.commonNext(language), isEnabled: true) {
                    onContinue()
                }
                .accessibilityIdentifier("onboarding.goal.next")
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.lg)
        }
    }

    private func genderPill(_ gender: OnboardingGender, title: String) -> some View {
        let selected = vm.selectedGender == gender
        return Button {
            vm.applyGoalsForGender(gender)
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(selected ? AppColors.charcoal : AppColors.greyText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(selected ? AppColors.pureWhite : AppColors.pureWhite.opacity(0.58))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(selected ? AppColors.coralRed.opacity(0.85) : AppColors.charcoal.opacity(0.06), lineWidth: selected ? 1.5 : 1)
                }
                .shadow(color: selected ? AppColors.coralRed.opacity(0.10) : .clear, radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var guidelineCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text(AppCopy.onboardingGuidelinesTitle(language))
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            HStack(spacing: AppSpacing.md) {
                goalMetric(
                    label: AppCopy.onboardingDailyGuide(language),
                    value: "\(Int(vm.dailyGoal))g"
                )
                goalMetric(
                    label: AppCopy.onboardingWeeklyGuide(language),
                    value: "\(Int(vm.weeklyGoal))g"
                )
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.pureWhite.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: AppColors.mintGreen.opacity(0.10), radius: 18, y: 8)
    }

    private func goalMetric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(label)
                .font(AppFonts.sublabel(for: language, size: 12))
                .foregroundStyle(AppColors.greyText)
            Text(value)
                .font(AppFonts.statCardValue())
                .foregroundStyle(AppColors.charcoal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColors.cream.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func stepperRow(title: String, value: Int, decrement: @escaping () -> Void, increment: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(AppFonts.body(for: language, size: 15))
            Spacer()
            Button("−", action: decrement)
                .foregroundStyle(AppColors.coralRed)
            Text("\(value)")
                .font(AppFonts.cardTitle())
                .frame(minWidth: 44)
            Button("+", action: increment)
                .foregroundStyle(AppColors.coralRed)
        }
        .padding(AppSpacing.md)
        .background(AppColors.pureWhite.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    GenderGoalView(vm: OnboardingViewModel(), language: .ja, onBack: {}, onContinue: {})
        .background(AppGradients.onboardingFullScreen)
}
