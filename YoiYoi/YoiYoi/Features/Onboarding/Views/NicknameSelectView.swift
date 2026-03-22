import SwiftUI

/// DESIGN.md「オンボーディング: ニックネーム選択画面」
struct NicknameSelectView: View {
    @Bindable var vm: OnboardingViewModel
    var language: SupportedLanguage
    var onBack: () -> Void
    var onComplete: () -> Void

    @State private var loadError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                HStack {
                    Button("戻る", action: onBack)
                        .font(AppFonts.body(for: language, size: 16))
                        .foregroundStyle(AppColors.coralRed)
                    Spacer()
                }

                Text("🎭")
                    .font(.system(size: 48))
                    .frame(maxWidth: .infinity)

                Text("あなたの相棒を選ぼう")
                    .font(AppFonts.screenTitle())
                    .foregroundStyle(AppColors.charcoal)
                    .frame(maxWidth: .infinity)

                previewCard

                Button {
                    vm.shuffleNickname()
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Text("🔀")
                        Text("シャッフル")
                            .font(AppFonts.body(for: language, size: 16))
                    }
                    .foregroundStyle(AppColors.coralRed)
                }
                .buttonStyle(.plain)

                if let loadError {
                    Text(loadError)
                        .font(AppFonts.sublabel(for: language, size: 13))
                        .foregroundStyle(AppColors.warmCoral)
                }

                labeledRow(title: "国旗") {
                    FlagPicker(
                        items: vm.flagOptions.map { FlagPicker.Item(id: $0, emoji: $0) },
                        selection: $vm.selectedFlag
                    )
                }

                labeledRow(title: "絵文字") {
                    FlagPicker(
                        items: vm.emojiOptions.map { FlagPicker.Item(id: $0, emoji: $0) },
                        selection: $vm.selectedEmoji
                    )
                }

                labeledRow(title: "形容詞") {
                    adjectiveOrNounStrip(options: vm.adjectiveOptions, selected: $vm.selectedAdjective)
                }

                labeledRow(title: "名詞") {
                    adjectiveOrNounStrip(options: vm.nounOptions, selected: $vm.selectedNoun)
                }

                PuffyButton(
                    title: "この相棒にする！🎉",
                    isEnabled: vm.selectedFlag != nil && vm.selectedEmoji != nil
                        && vm.selectedAdjective != nil && vm.selectedNoun != nil
                ) {
                    onComplete()
                }
            }
            .padding(AppSpacing.lg)
        }
        .onAppear {
            do {
                try vm.loadNicknameDataIfNeeded()
                loadError = nil
            } catch {
                loadError = "ニックネームデータを読み込めませんでした。"
            }
        }
    }

    private var previewCard: some View {
        let flag = vm.selectedFlag ?? "—"
        let emo = vm.selectedEmoji ?? "—"
        let adj = vm.selectedAdjective ?? "—"
        let noun = vm.selectedNoun ?? "—"
        return HStack(alignment: .center, spacing: AppSpacing.sm) {
            Text("\(flag) \(emo)")
                .font(.system(size: 24))
            Text("\(adj) \(noun)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.charcoal)
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.coralRed)
    }

    private func labeledRow(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFonts.sublabel(for: language, size: 13))
                .foregroundStyle(AppColors.greyText)
            content()
        }
    }

    private func adjectiveOrNounStrip(options: [String], selected: Binding<String?>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(options, id: \.self) { word in
                    let on = selected.wrappedValue == word
                    Button {
                        selected.wrappedValue = word
                    } label: {
                        PillTag(
                            text: word,
                            bgColor: on ? AppColors.coralRed : AppColors.pureWhite,
                            textColor: on ? AppColors.pureWhite : AppColors.charcoal,
                            isSelected: on
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    NicknameSelectView(vm: OnboardingViewModel(), language: .ja, onBack: {}, onComplete: {})
        .background(AppGradients.onboardingFullScreen)
}
