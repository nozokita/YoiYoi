import SwiftData
import SwiftUI

/// DESIGN.md「設定画面」テーマ（lavender）— `HomeView` と同型の固定ヒーロー + 下段スクロール。
struct SettingsRootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight() }

    private var appVersionLine: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WaveHeroView(height: heroHeight, gradient: AppGradients.heroSettings) {
                    VStack(spacing: AppSpacing.md) {
                        Text(AppCopy.settingsTitle(appState.currentLanguage))
                            .font(AppFonts.heroTitle())
                            .foregroundStyle(AppColors.pureWhite)
                        Text(AppCopy.settingsHeroSubtitle(appState.currentLanguage))
                            .font(AppFonts.heroSubtitle())
                            .foregroundStyle(AppColors.pureWhite.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, AppSpacing.lg)
                }
                .frame(height: heroHeight)
                .frame(maxWidth: .infinity)

                List {
                    Section {
                        Picker(AppCopy.settingsLanguagePicker(appState.currentLanguage), selection: $appState.currentLanguage) {
                            ForEach(SupportedLanguage.allCases) { lang in
                                Text("\(lang.flag) \(lang.displayName)")
                                    .tag(lang)
                            }
                        }
                        .pickerStyle(.menu)
                        .foregroundStyle(AppColors.charcoal)
                        .tint(AppColors.coralRed)
                        .listRowBackground(AppColors.cream)
                    } header: {
                        Text(AppCopy.settingsLanguageSection(appState.currentLanguage))
                            .font(.caption)
                            .foregroundStyle(AppColors.greyText)
                            .textCase(nil)
                    } footer: {
                        Text(AppCopy.settingsLanguageFooter(appState.currentLanguage))
                            .font(.caption2)
                            .foregroundStyle(AppColors.greyText.opacity(0.9))
                    }

                    Section {
                        HStack {
                            Text(AppCopy.settingsVersion(appState.currentLanguage))
                                .foregroundStyle(AppColors.charcoal)
                            Spacer()
                            Text(appVersionLine)
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(AppColors.greyText)
                        }
                        .listRowBackground(AppColors.cream)
                    } header: {
                        Text(AppCopy.settingsAppInfo(appState.currentLanguage))
                            .font(.caption)
                            .foregroundStyle(AppColors.greyText)
                            .textCase(nil)
                    }

                    Section {
                        Text(AppCopy.settingsPlaceholder(appState.currentLanguage))
                            .font(.subheadline)
                            .foregroundStyle(AppColors.greyText)
                            .listRowBackground(AppColors.cream)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(AppColors.cream)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.cream)
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: appState.currentLanguage) { _, new in
                syncLanguageToProfile(new)
            }
        }
    }

    private func syncLanguageToProfile(_ lang: SupportedLanguage) {
        let desc = FetchDescriptor<UserProfile>()
        guard let profile = try? modelContext.fetch(desc).first else { return }
        profile.language = lang.rawValue
        try? modelContext.save()
    }
}

#Preview {
    SettingsRootView()
        .environmentObject(AppState())
        .modelContainer(for: [UserProfile.self, DrinkRecord.self], inMemory: true)
}
