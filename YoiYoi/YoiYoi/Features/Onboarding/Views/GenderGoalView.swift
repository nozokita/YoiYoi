import SwiftUI

/// DESIGN.md「オンボーディング: 性別・目標画面」
struct GenderGoalView: View {
    @Bindable var vm: OnboardingViewModel
    var language: SupportedLanguage
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                HStack {
                    Button(AppCopy.commonBack(language), action: onBack)
                        .font(AppFonts.body(for: language, size: 16))
                        .foregroundStyle(AppColors.coralRed)
                    Spacer()
                }

                SVGIcon(icon: .goal, size: 48, color: AppColors.coralRed)
                    .frame(maxWidth: .infinity)

                Text(AppCopy.onboardingGoalTitle(language))
                    .font(AppFonts.screenTitle())
                    .foregroundStyle(AppColors.charcoal)
                    .frame(maxWidth: .infinity)

                Text(AppCopy.onboardingGenderLabel(language))
                    .font(AppFonts.sublabel(for: language, size: 13))
                    .foregroundStyle(AppColors.greyText)

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
            .padding(AppSpacing.lg)
        }
    }

    private func genderPill(_ gender: OnboardingGender, title: String) -> some View {
        let selected = vm.selectedGender == gender
        return Button {
            vm.applyGoalsForGender(gender)
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(selected ? AppColors.pureWhite : AppColors.charcoal)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(selected ? AppColors.coralRed : AppColors.pureWhite)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(selected ? Color.clear : AppColors.greyText.opacity(0.2), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private var guidelineCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                SVGIcon(icon: .chart, size: 24, color: AppColors.mintGreen)
                Text(AppCopy.onboardingGuidelinesTitle(language))
                    .font(AppFonts.cardTitle())
                    .foregroundStyle(AppColors.charcoal)
            }
            HStack {
                Text(AppCopy.onboardingDailyGuide(language))
                    .font(AppFonts.body(for: language, size: 15))
                    .foregroundStyle(AppColors.charcoal)
                Spacer()
                Text("\(Int(vm.dailyGoal))g")
                    .font(AppFonts.statCardValue())
                    .foregroundStyle(AppColors.mintGreen)
            }
            HStack {
                Text(AppCopy.onboardingWeeklyGuide(language))
                    .font(AppFonts.body(for: language, size: 15))
                    .foregroundStyle(AppColors.charcoal)
                Spacer()
                Text("\(Int(vm.weeklyGoal))g")
                    .font(AppFonts.statCardValue())
                    .foregroundStyle(AppColors.mintGreen)
            }
            Text(AppCopy.onboardingGenderAutoHint(language))
                .font(AppFonts.sublabel(for: language, size: 12))
                .foregroundStyle(AppColors.greyText)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.mintGreen)
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
        .background(AppColors.pureWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    GenderGoalView(vm: OnboardingViewModel(), language: .ja, onBack: {}, onContinue: {})
        .background(AppGradients.onboardingFullScreen)
}
