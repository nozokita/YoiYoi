import SwiftData
import SwiftUI

/// 設定から `UserProfile` のニックネーム 4 要素を編集（オンボの `NicknameSelectView` と同型の操作感）。
struct SettingsNicknameEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var flagOptions: [String] = []
    @State private var emojiOptions: [String] = []
    @State private var adjectiveOptions: [String] = []
    @State private var nounOptions: [String] = []

    @State private var selectedFlag: String?
    @State private var selectedEmoji: String?
    @State private var selectedAdjective: String?
    @State private var selectedNoun: String?

    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    previewCard

                    Button {
                        shuffle()
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Text("🔀")
                            Text(AppCopy.settingsShuffle(appState.currentLanguage))
                                .font(AppFonts.body(for: appState.currentLanguage, size: 16))
                        }
                        .foregroundStyle(AppColors.coralRed)
                    }
                    .buttonStyle(.plain)

                    if let loadError {
                        Text(loadError)
                            .font(AppFonts.sublabel(for: appState.currentLanguage, size: 13))
                            .foregroundStyle(AppColors.warmCoral)
                    }

                    labeledRow(title: AppCopy.settingsNicknameFlag(appState.currentLanguage)) {
                        FlagPicker(
                            items: flagOptions.map { FlagPicker.Item(id: $0, emoji: $0) },
                            selection: $selectedFlag
                        )
                        .frame(height: 52)
                    }

                    labeledRow(title: AppCopy.settingsNicknameEmoji(appState.currentLanguage)) {
                        FlagPicker(
                            items: emojiOptions.map { FlagPicker.Item(id: $0, emoji: $0) },
                            selection: $selectedEmoji
                        )
                        .frame(height: 52)
                    }

                    labeledRow(title: AppCopy.settingsNicknameAdjective(appState.currentLanguage)) {
                        wordStrip(options: adjectiveOptions, selected: $selectedAdjective)
                    }

                    labeledRow(title: AppCopy.settingsNicknameNoun(appState.currentLanguage)) {
                        wordStrip(options: nounOptions, selected: $selectedNoun)
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.cream)
            .navigationTitle(AppCopy.settingsNicknameTitle(appState.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppCopy.settingsCancel(appState.currentLanguage)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppCopy.settingsSave(appState.currentLanguage)) {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            loadLists()
            loadFromProfile()
        }
        .onChange(of: appState.currentLanguage) { _, _ in
            loadLists()
        }
    }

    private var canSave: Bool {
        selectedFlag != nil && selectedEmoji != nil && selectedAdjective != nil && selectedNoun != nil
    }

    private var previewCard: some View {
        let flag = selectedFlag ?? "—"
        let emo = selectedEmoji ?? "—"
        let adj = selectedAdjective ?? "—"
        let noun = selectedNoun ?? "—"
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
                .font(AppFonts.sublabel(for: appState.currentLanguage, size: 13))
                .foregroundStyle(AppColors.greyText)
            content()
        }
    }

    private func wordStrip(options: [String], selected: Binding<String?>) -> some View {
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
        .frame(height: 44)
    }

    private func loadLists() {
        let lang = appState.currentLanguage
        do {
            flagOptions = try NicknamePresets.flags()
            emojiOptions = try NicknamePresets.emojis()
            adjectiveOptions = try NicknamePresets.adjectives(for: lang)
            nounOptions = try NicknamePresets.nouns(for: lang)
            loadError = nil
        } catch {
            loadError = AppCopy.settingsNicknameLoadError(appState.currentLanguage)
        }
    }

    private func loadFromProfile() {
        let desc = FetchDescriptor<UserProfile>()
        guard let p = try? modelContext.fetch(desc).first else { return }
        selectedFlag = p.nicknameFlag
        selectedEmoji = p.nicknameEmoji
        selectedAdjective = p.nicknameAdjective
        selectedNoun = p.nicknameNoun
    }

    private func shuffle() {
        if let f = flagOptions.randomElement() { selectedFlag = f }
        if let e = emojiOptions.randomElement() { selectedEmoji = e }
        if let a = adjectiveOptions.randomElement() { selectedAdjective = a }
        if let n = nounOptions.randomElement() { selectedNoun = n }
    }

    private func save() {
        guard let f = selectedFlag, let e = selectedEmoji, let a = selectedAdjective, let n = selectedNoun else { return }
        let desc = FetchDescriptor<UserProfile>()
        guard let p = try? modelContext.fetch(desc).first else { return }
        p.nicknameFlag = f
        p.nicknameEmoji = e
        p.nicknameAdjective = a
        p.nicknameNoun = n
        try? modelContext.save()
        NotificationCenter.default.post(name: .userProfileDidChange, object: nil)
        Task {
            guard let uid = AuthService.currentUID else { return }
            try? await FirestoreService.shared.syncUserDocument(uid: uid, profile: p)
        }
    }
}

#Preview {
    SettingsNicknameEditView()
        .environmentObject(AppState())
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
