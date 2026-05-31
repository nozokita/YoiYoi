import SwiftUI

/// DESIGN.md「オンボーディング: 言語選択画面」
struct LanguageSelectView: View {
    @Bindable var vm: OnboardingViewModel
    /// 表示用（選択前は `AppState.currentLanguage` を渡す）
    var displayLanguage: SupportedLanguage
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                OnboardingHeroHeader(
                    stepText: "1 / 3",
                    title: AppCopy.onboardingLanguageTitle(displayLanguage),
                    language: displayLanguage
                )

                VStack(spacing: AppSpacing.md) {
                    ForEach(SupportedLanguage.allCases) { lang in
                        languageCard(lang)
                    }
                }

                PuffyButton(title: AppCopy.commonNext(displayLanguage), isEnabled: vm.selectedLanguage != nil) {
                    onContinue()
                }
                .accessibilityIdentifier("onboarding.language.next")
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.lg)
        }
    }

    @ViewBuilder
    private func languageCard(_ lang: SupportedLanguage) -> some View {
        let selected = vm.selectedLanguage == lang
        Button {
            vm.selectedLanguage = lang
        } label: {
            HStack(spacing: AppSpacing.md) {
                Text(lang.rawValue.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(selected ? AppColors.pureWhite : AppColors.coralRed)
                    .frame(width: 44, height: 44)
                    .background(selected ? AppColors.coralRed : AppColors.coralRed.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(lang.displayName)
                        .font(AppFonts.body(for: lang, size: 17))
                        .foregroundStyle(AppColors.charcoal)
                    Text(lang.rawValue.uppercased())
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.greyText.opacity(0.72))
                }
                Spacer(minLength: 0)
                OnboardingSelectionMark(isSelected: selected)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selected ? AppColors.surfaceElevated : AppColors.surfaceElevated.opacity(0.74))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(selected ? AppColors.coralRed.opacity(0.85) : AppColors.hairline, lineWidth: selected ? 1.5 : 1)
            }
            .themedShadow(themeColor: selected ? AppColors.coralRed : AppColors.hairline, opacity: selected ? 0.11 : 0.06, radius: selected ? 16 : 10, y: selected ? 8 : 5)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("onboarding.language.\(lang.rawValue)")
    }
}

#Preview {
    LanguageSelectView(vm: OnboardingViewModel(), displayLanguage: .ja) {}
        .background(AppGradients.onboardingFullScreen)
}
