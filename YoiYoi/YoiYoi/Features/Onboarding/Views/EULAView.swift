import SwiftUI

enum EULALoader {
    static func load(language: SupportedLanguage, bundle: Bundle = .main) -> String {
        let base = "eula_\(language.rawValue)"
        let url = bundle.url(forResource: base, withExtension: "md", subdirectory: "EULA")
            ?? bundle.url(forResource: base, withExtension: "md")
        guard let url,
              let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            return "（利用規約を読み込めませんでした。アプリを再インストールするか、開発者にお問い合わせください。）"
        }
        return text
    }
}

/// DESIGN.md「オンボーディング: EULA 同意画面」
struct EULAView: View {
    @Bindable var vm: OnboardingViewModel
    /// 表示用テキストの言語（初回は `AppState.currentLanguage` を渡す）。
    var displayLanguage: SupportedLanguage
    var onContinue: () -> Void

    @State private var agreed = false
    @State private var eulaBody = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("📜")
                    .font(.system(size: 48))
                    .frame(maxWidth: .infinity)

                Text("利用規約への同意")
                    .font(AppFonts.screenTitle())
                    .foregroundStyle(AppColors.charcoal)
                    .frame(maxWidth: .infinity)

                Text(eulaBody)
                    .font(AppFonts.body(for: displayLanguage, size: 15))
                    .foregroundStyle(AppColors.charcoal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpacing.md)
                    .frame(minHeight: 280, alignment: .topLeading)
                    .contentCard(themeColor: AppColors.coralRed)

                Toggle(isOn: $agreed) {
                    Text("利用規約・プライバシーポリシーに同意する")
                        .font(AppFonts.body(for: displayLanguage, size: 15))
                        .foregroundStyle(AppColors.charcoal)
                }
                .tint(AppColors.coralRed)

                PuffyButton(title: "同意して始める", isEnabled: agreed) {
                    vm.acceptEULA()
                    onContinue()
                }

                Text("※ 同意いただけない場合は\nアプリをご利用いただけません")
                    .font(AppFonts.sublabel(for: displayLanguage, size: 12))
                    .foregroundStyle(AppColors.greyText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(AppSpacing.lg)
        }
        .onAppear {
            eulaBody = EULALoader.load(language: displayLanguage)
        }
        .onChange(of: displayLanguage) { _, new in
            eulaBody = EULALoader.load(language: new)
        }
    }
}

#Preview {
    EULAView(vm: OnboardingViewModel(), displayLanguage: .ja) {}
        .background(AppGradients.onboardingFullScreen)
}
