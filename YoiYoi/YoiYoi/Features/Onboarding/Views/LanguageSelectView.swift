import SwiftUI

/// DESIGN.md「オンボーディング: 言語選択画面」
struct LanguageSelectView: View {
    @Bindable var vm: OnboardingViewModel
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("🌏")
                    .font(.system(size: 48))
                    .frame(maxWidth: .infinity)

                Text("言語を選んでね")
                    .font(AppFonts.screenTitle())
                    .foregroundStyle(AppColors.charcoal)
                    .frame(maxWidth: .infinity)

                VStack(spacing: AppSpacing.md) {
                    ForEach(SupportedLanguage.allCases) { lang in
                        languageCard(lang)
                    }
                }

                PuffyButton(title: "つぎへ", isEnabled: vm.selectedLanguage != nil) {
                    onContinue()
                }
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
    }
}

#Preview {
    LanguageSelectView(vm: OnboardingViewModel()) {}
        .background(AppGradients.onboardingFullScreen)
}
