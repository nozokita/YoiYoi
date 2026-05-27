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
                    detail: AppCopy.onboardingLocalOnlyDetail(displayLanguage),
                    language: displayLanguage
                )

                VStack(spacing: AppSpacing.md) {
                    ForEach(SupportedLanguage.allCases) { lang in
                        languageCard(lang)
                    }
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(AppCopy.onboardingLocalOnlyTitle(displayLanguage))
                        .font(AppFonts.cardTitle())
                        .foregroundStyle(AppColors.charcoal)
                    Text(AppCopy.onboardingLocalOnlyDetail(displayLanguage))
                        .font(AppFonts.sublabel(for: displayLanguage, size: 13))
                        .foregroundStyle(AppColors.greyText)
                }
                .multilineTextAlignment(.leading)
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity)
                .background(AppColors.pureWhite.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(AppColors.mintGreen)
                        .frame(width: 4)
                        .padding(.vertical, AppSpacing.md)
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
            .background(selected ? AppColors.pureWhite : AppColors.pureWhite.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(selected ? AppColors.coralRed.opacity(0.85) : AppColors.charcoal.opacity(0.06), lineWidth: selected ? 1.5 : 1)
            }
            .shadow(color: selected ? AppColors.coralRed.opacity(0.12) : .black.opacity(0.035), radius: selected ? 16 : 10, y: selected ? 8 : 5)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("onboarding.language.\(lang.rawValue)")
    }
}

#Preview {
    LanguageSelectView(vm: OnboardingViewModel(), displayLanguage: .ja) {}
        .background(AppGradients.onboardingFullScreen)
}
