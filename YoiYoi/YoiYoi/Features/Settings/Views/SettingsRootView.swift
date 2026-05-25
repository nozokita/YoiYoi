import SwiftData
import SwiftUI

/// DESIGN.md「設定画面」テーマ（lavender）— `HomeView` と同型の固定ヒーロー + 下段スクロール。
struct SettingsRootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var showGoalsEditor = false
    @State private var showNotificationsEditor = false

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
                    VStack(spacing: AppSpacing.sm) {
                        Text(AppCopy.settingsTitle(appState.currentLanguage))
                            .font(AppFonts.heroTitle())
                            .foregroundStyle(AppColors.pureWhite)
                        Text(AppCopy.settingsHeroSubtitle(appState.currentLanguage))
                            .font(AppFonts.heroSubtitle())
                            .foregroundStyle(AppColors.pureWhite.opacity(0.85))

                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, AppSpacing.sm)
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
                        Button {
                            showGoalsEditor = true
                        } label: {
                            HStack {
                                Text(AppCopy.settingsGoalsRow(appState.currentLanguage))
                                    .foregroundStyle(AppColors.charcoal)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppColors.greyText.opacity(0.7))
                            }
                        }
                        .listRowBackground(AppColors.cream)
                    } header: {
                        Text(AppCopy.settingsSectionGoalsProfile(appState.currentLanguage))
                            .font(.caption)
                            .foregroundStyle(AppColors.greyText)
                            .textCase(nil)
                    }

                    Section {
                        Button {
                            showNotificationsEditor = true
                        } label: {
                            HStack {
                                Text(AppCopy.settingsNotificationsRow(appState.currentLanguage))
                                    .foregroundStyle(AppColors.charcoal)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppColors.greyText.opacity(0.7))
                            }
                        }
                        .listRowBackground(AppColors.cream)
                    } header: {
                        Text(AppCopy.settingsNotificationsSection(appState.currentLanguage))
                            .font(.caption)
                            .foregroundStyle(AppColors.greyText)
                            .textCase(nil)
                    }

                    Section {
                        Link(destination: AppLegalLinks.privacyPolicyURL) {
                            HStack {
                                Text(AppCopy.settingsPrivacyPolicyRow(appState.currentLanguage))
                                    .foregroundStyle(AppColors.charcoal)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(AppColors.greyText.opacity(0.7))
                            }
                        }
                        .listRowBackground(AppColors.cream)
                    } header: {
                        Text(AppCopy.settingsDataPrivacySection(appState.currentLanguage))
                            .font(.caption)
                            .foregroundStyle(AppColors.greyText)
                            .textCase(nil)
                    } footer: {
                        Text(AppCopy.settingsDataPrivacyFooter(appState.currentLanguage))
                            .font(.caption2)
                            .foregroundStyle(AppColors.greyText.opacity(0.9))
                    }

                    Section {
                        Text(AppCopy.settingsMedicalDisclaimer(appState.currentLanguage))
                            .font(AppFonts.sublabel(for: appState.currentLanguage, size: 12))
                            .foregroundStyle(AppColors.greyText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                            .listRowBackground(AppColors.cream)
                            .listRowSeparator(.hidden)
                    }

                    #if DEBUG
                    Section {
                        Button {
                            DebugOnboarding.resetForReplay(
                                modelContext: modelContext,
                                appState: appState,
                            )
                        } label: {
                            Text("🔧 DEBUG: オンボを再表示")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.warmCoral)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .listRowBackground(AppColors.cream)
                    } header: {
                        Text("Debug")
                            .font(.caption)
                            .foregroundStyle(AppColors.greyText)
                            .textCase(nil)
                    } footer: {
                        Text("Scheme の Run に \(DebugOnboarding.launchArgument) を付けても同様に先頭から開けます。")
                            .font(.caption2)
                            .foregroundStyle(AppColors.greyText.opacity(0.9))
                    }
                    #endif
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                // FAB が重なる分だけ下に余白を確保して、最下部のセルが押しやすい位置に来るようにする。
                .safeAreaInset(edge: .bottom) {
                    Color.clear
                        .frame(height: 80)
                        .background(AppColors.cream)
                }
                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(AppColors.cream)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.cream)
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: appState.currentLanguage) { _, new in
                syncLanguageToProfile(new)
            }
            .sheet(isPresented: $showGoalsEditor) {
                SettingsGoalsEditView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showNotificationsEditor) {
                SettingsNotificationsView()
                    .environmentObject(appState)
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
