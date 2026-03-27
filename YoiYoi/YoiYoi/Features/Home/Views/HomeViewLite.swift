import SwiftData
import SwiftUI

/// 白画面切り分け用の段階的 HomeView。依存を 1 つずつ足して、どこで壊れるか特定する。
/// Step 2: EnvironmentObject（言語表示まで）。
/// Step 3: SwiftData（最小 fetch 件数表示）まで追加していく。
/// Step 4: ScrollView + 静的カード（Text のみ）を追加する。
/// Step 5: `WaveHeroView`（矩形グラデ＋`.clipped()`）。
/// Step 6: ヒーロー内に `AlcoholMeterView`（SwiftData の今日合計＋目標）。
/// Step 7-1: 下段カード1枚目だけ「今週のまとめ（週合計）」を最小導入。
/// Step 7-2: 下段カード2枚目だけ「今日のドリンク件数」を最小導入。
/// Step 7-3: 下段カード3枚目だけ「みんなの様子（準備中）」へ最小導入。
/// 週まとめカードは **週合計の単行のみ**（複行・WaveShape 等で白画面が出たため当面これに戻す）。
///
/// **白画面対策**: ヒーローを **縦 `ScrollView` の内側**に置くとタブシェル環境でレイアウトが潰れることがあるため、
/// **`VStack` で固定高ヒーロー + 下段だけ `ScrollView`** とする。
struct HomeViewLite: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var drinkRecordCount: Int = 0
    @State private var profileCount: Int = 0
    @State private var todaysDrinkCount: Int = 0
    @State private var todayConsumed: Double = 0
    @State private var weeklyConsumed: Double = 0
    @State private var dailyGoalGrams: Double = 40

    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight() }

    var body: some View {
        VStack(spacing: 0) {
            WaveHeroView(height: heroHeight, gradient: AppGradients.heroHome) {
                VStack(spacing: AppSpacing.md) {
                    Text("HomeViewLite — Step 6")
                        .font(AppFonts.heroTitle())
                        .foregroundStyle(AppColors.pureWhite)
                        .multilineTextAlignment(.center)
                    Text("WaveHeroView + AlcoholMeterView")
                        .font(AppFonts.heroSubtitle())
                        .foregroundStyle(AppColors.pureWhite.opacity(0.85))
                        .multilineTextAlignment(.center)

                    AlcoholMeterView(consumed: todayConsumed, dailyGoal: dailyGoalGrams)
                }
                .padding(.bottom, AppSpacing.lg)
            }
            .frame(height: heroHeight)
            .frame(maxWidth: .infinity)

            ScrollView {
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

                    Text("Step 6: メーター（今日 \(Int(todayConsumed))g / 目標 \(Int(dailyGoalGrams))g）")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        TextCard(title: "今週のまとめ", content: "週合計: \(weeklyConsumedText)")
                        TextCard(title: "今日のドリンク", content: "今日の記録: \(todaysDrinkCount)件")
                        TextCard(title: "みんなの様子", content: "公開準備中（もっと見る →）")
                    }
                    .padding(.horizontal, 16)

                    Color.clear.frame(height: 48)
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.coralRed)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(AppColors.coralRed)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.coralRed)
        .onAppear {
            AppLaunchDiagnostics.log("HomeViewLite.onAppear (white-screen fix: weekly single line, no WaveShape clip, no ScrollView Spacer)")

            let calendar = Calendar.current
            let now = Date()

            let drinkDescriptor = FetchDescriptor<DrinkRecord>()
            let drinks = (try? modelContext.fetch(drinkDescriptor)) ?? []
            let profileDescriptor = FetchDescriptor<UserProfile>()
            let profiles = (try? modelContext.fetch(profileDescriptor)) ?? []

            drinkRecordCount = drinks.count
            profileCount = profiles.count
            todaysDrinkCount = drinks.filter { calendar.isDate($0.loggedAt, inSameDayAs: now) }.count

            dailyGoalGrams = profiles.first?.dailyGoalGrams ?? 40
            todayConsumed = AlcoholCalculator.dailyTotal(gramsFrom: drinks, on: now, calendar: calendar)
            weeklyConsumed = AlcoholCalculator.weeklyTotal(gramsFrom: drinks, inWeekOf: now, calendar: calendar)
        }
    }

    private var weeklyConsumedText: String {
        if weeklyConsumed == floor(weeklyConsumed) {
            return "\(Int(weeklyConsumed))g"
        }
        return String(format: "%.1fg", weeklyConsumed)
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
