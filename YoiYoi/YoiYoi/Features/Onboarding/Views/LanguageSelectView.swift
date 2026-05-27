import SwiftUI

/// DESIGN.md「オンボーディング: 言語選択画面」
struct LanguageSelectView: View {
    @Bindable var vm: OnboardingViewModel
    /// 表示用（選択前は `AppState.currentLanguage` を渡す）
    var displayLanguage: SupportedLanguage
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("🌏")
                    .font(.system(size: 48))
                    .frame(maxWidth: .infinity)

                Text(AppCopy.onboardingLanguageTitle(displayLanguage))
                    .font(AppFonts.screenTitle())
                    .foregroundStyle(AppColors.charcoal)
                    .frame(maxWidth: .infinity)

                VStack(spacing: AppSpacing.md) {
                    ForEach(SupportedLanguage.allCases) { lang in
                        languageCard(lang)
                    }
                }

                VStack(spacing: AppSpacing.xs) {
                    Text(AppCopy.onboardingLocalOnlyTitle(displayLanguage))
                        .font(AppFonts.cardTitle())
                        .foregroundStyle(AppColors.charcoal)
                    Text(AppCopy.onboardingLocalOnlyDetail(displayLanguage))
                        .font(AppFonts.sublabel(for: displayLanguage, size: 13))
                        .foregroundStyle(AppColors.greyText)
                }
                .multilineTextAlignment(.center)
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity)
                .contentCard(themeColor: AppColors.mintGreen)

                PuffyButton(title: AppCopy.commonNext(displayLanguage), isEnabled: vm.selectedLanguage != nil) {
                    onContinue()
                }
                .accessibilityIdentifier("onboarding.language.next")
            }
            .padding(AppSpacing.lg)
        }
    }

    @ViewBuilder
    private func languageCard(_ lang: SupportedLanguage) -> some View {
        let selected = vm.selectedLanguage == lang
        Button {
            vm.selectedLanguage = lang
        } label: {
            HStack(spacing: AppSpacing.md) {
                Text(lang.flag)
                    .font(.system(size: 28))
                Text(lang.displayName)
                    .font(AppFonts.body(for: lang, size: 17))
                    .foregroundStyle(AppColors.charcoal)
                Spacer(minLength: 0)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(selected ? AppColors.coralRed : Color.clear, lineWidth: 2.5)
            }
            .themedShadow(themeColor: AppColors.coralRed, opacity: selected ? 0.12 : 0.08, radius: 12, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("onboarding.language.\(lang.rawValue)")
    }
}

#Preview {
    LanguageSelectView(vm: OnboardingViewModel(), displayLanguage: .ja) {}
        .background(AppGradients.onboardingFullScreen)
}
