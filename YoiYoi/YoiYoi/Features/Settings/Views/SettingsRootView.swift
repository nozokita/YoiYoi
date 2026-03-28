import SwiftUI

/// DESIGN.md「設定画面」テーマ（lavender）— `HomeView` と同型の固定ヒーロー + 下段スクロール。
struct SettingsRootView: View {
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
                        Text("設定")
                            .font(AppFonts.heroTitle())
                            .foregroundStyle(AppColors.pureWhite)
                        Text("アプリとデータの管理")
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
                        HStack {
                            Text("アプリの言語")
                                .foregroundStyle(AppColors.charcoal)
                            Spacer()
                            Text("\(appState.currentLanguage.flag) \(appState.currentLanguage.displayName)")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.greyText)
                        }
                        .listRowBackground(AppColors.cream)
                    } header: {
                        Text("表示言語")
                            .font(.caption)
                            .foregroundStyle(AppColors.greyText)
                            .textCase(nil)
                    }

                    Section {
                        HStack {
                            Text("バージョン")
                                .foregroundStyle(AppColors.charcoal)
                            Spacer()
                            Text(appVersionLine)
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(AppColors.greyText)
                        }
                        .listRowBackground(AppColors.cream)
                    } header: {
                        Text("アプリ情報")
                            .font(.caption)
                            .foregroundStyle(AppColors.greyText)
                            .textCase(nil)
                    }

                    Section {
                        Text("飲酒目標・通知・データのエクスポートなどは、次の段階でここに追加します。")
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
        }
    }
}

#Preview {
    SettingsRootView()
        .environmentObject(AppState())
}
