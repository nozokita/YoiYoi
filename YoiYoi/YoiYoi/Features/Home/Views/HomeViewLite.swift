import SwiftData
import SwiftUI

/// 白画面切り分け用の段階的 HomeView。依存を 1 つずつ足して、どこで壊れるか特定する。
/// Step 2: EnvironmentObject（言語表示まで）。
/// Step 3: SwiftData（最小 fetch 件数表示）まで追加していく。
/// Step 4: ScrollView + 静的カード（Text のみ）を追加する。
/// Step 5: `WaveHeroView`（矩形 `.clipped()`、`WaveShape` は未使用）。
struct HomeViewLite: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var drinkRecordCount: Int = 0
    @State private var profileCount: Int = 0

    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight() }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                WaveHeroView(height: heroHeight, gradient: AppGradients.heroHome) {
                    VStack(spacing: AppSpacing.md) {
                        Text("HomeViewLite — Step 5")
                            .font(AppFonts.heroTitle())
                            .foregroundStyle(AppColors.pureWhite)
                            .multilineTextAlignment(.center)
                        Text("WaveHeroView（Rectangle.fill + .clipped()）")
                            .font(AppFonts.heroSubtitle())
                            .foregroundStyle(AppColors.pureWhite.opacity(0.85))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, AppSpacing.lg)
                }
                .frame(height: heroHeight)
                .frame(maxWidth: .infinity)

                VStack(spacing: 16) {
                    Text("Step 2: EnvironmentObject（言語: \(appState.currentLanguage.displayName)）")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.top, AppSpacing.lg)

                    Text("Step 3: SwiftData counts -> records=\(drinkRecordCount), profiles=\(profileCount)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))

                    Text("Step 4: ScrollView + 静的カード（Textのみ）")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))

                    Text("Step 5: 上段に WaveHeroView を接続")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        TextCard(title: "カード1（週まとめ 風）", content: "静的テキストだけ")
                        TextCard(title: "カード2（今日ドリンク 風）", content: "SwiftData の件数: records=\(drinkRecordCount)")
                        TextCard(title: "カード3（みんなの様子 風）", content: "profiles=\(profileCount)")
                    }
                    .padding(.horizontal, 16)

                    // ScrollView が「高さ 0」になって潰れるケースの回避のため最低高さっぽく確保
                    Spacer(minLength: 48)
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.coralRed)
            }
        }
        .scrollIndicators(.hidden)
        .background(AppColors.coralRed)
        .onAppear {
            AppLaunchDiagnostics.log("HomeViewLite.onAppear (Step 5: WaveHeroView + ScrollView cards)")

            // 依存増加の影響を最小化するため、最小限の fetch 件数だけ表示する。
            let drinkDescriptor = FetchDescriptor<DrinkRecord>()
            let drinks = (try? modelContext.fetch(drinkDescriptor)) ?? []
            let profileDescriptor = FetchDescriptor<UserProfile>()
            let profiles = (try? modelContext.fetch(profileDescriptor)) ?? []

            drinkRecordCount = drinks.count
            profileCount = profiles.count
        }
    }

    private struct TextCard: View {
        let title: String
        let content: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppColors.charcoal)
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.greyText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.pureWhite.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: AppColors.charcoal.opacity(0.08), radius: 10, y: 4)
        }
    }
}

#Preview {
    HomeViewLite()
        .environmentObject(AppState())
        .modelContainer(for: [DrinkRecord.self, UserProfile.self], inMemory: true)
}
