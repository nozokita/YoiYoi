import SwiftData
import SwiftUI

/// DESIGN.md「ホーム画面」— ウェーブヒーロー + ローカルの振り返りカード群。
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState

    @State private var viewModel = HomeViewModel()

    /// メーター＋サブテキストが収まり、下のカード負マージンで隠れないよう少し高めにする。
    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight(fraction: 0.40, minimum: 300) }

    /// 縦 `ScrollView` 内の横 `ScrollView` は高さ未確定だと全体レイアウトが潰れて真っ白になることがある（`docs/DEBUG_WHITE_SCREEN.md`）。
    private var drinkPillRowHeight: CGFloat { 44 }

    /// ヒーロー（グラデ＋Wave クリップ）を `ScrollView` の内側に置くと、タブシェル等の親によっては
    /// **全体が真っ白で描画されない**環境がある。ヒーローは固定高で外に出し、下段だけ `ScrollView` にする。
    var body: some View {
        VStack(spacing: 0) {
            WaveHeroView(height: heroHeight, gradient: AppGradients.heroHome) {
                VStack(spacing: 6) {
                    Text(AppCopy.homePureAlcoholLabel(appState.currentLanguage))
                        .font(AppFonts.heroSubtitle())
                        .foregroundStyle(AppColors.pureWhite.opacity(0.85))
                        .multilineTextAlignment(.center)

                    Text(AppCopy.homeGreeting(appState.currentLanguage))
                        .font(AppFonts.heroTitle())
                        .foregroundStyle(AppColors.pureWhite)
                        .multilineTextAlignment(.center)

                    AlcoholMeterView(
                        consumed: viewModel.todayConsumed,
                        dailyGoal: viewModel.dailyGoal
                    )

                    Text(viewModel.meterSubtext(language: appState.currentLanguage))
                        .font(AppFonts.heroSubtitle())
                        .foregroundStyle(AppColors.pureWhite.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
                }
                .padding(.bottom, AppSpacing.md)
            }
            .frame(height: heroHeight)
            .frame(maxWidth: .infinity)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    weeklySummarySection
                    todayDrinksSection
                }
                .padding(.horizontal, AppSpacing.lg)
                /// 強い負マージンはヒーロー内の白文字をカード下に隠す。重なりは控えめに。
                .padding(.top, -AppSpacing.sm)
                .padding(.bottom, AppSpacing.xxl)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cream)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(AppColors.cream)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
        .onAppear {
            viewModel.refresh(modelContext: modelContext)
        }
        .onChange(of: appState.currentLanguage) { _, _ in
            viewModel.refresh(modelContext: modelContext)
        }
        .onChange(of: scenePhase) { _, new in
            if new == .active {
                viewModel.refresh(modelContext: modelContext)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .drinkLogSheetDismissed)) { _ in
            viewModel.refresh(modelContext: modelContext)
        }
        .onReceive(NotificationCenter.default.publisher(for: .userProfileDidChange)) { _ in
            viewModel.refresh(modelContext: modelContext)
        }
    }

    // MARK: - 今週のまとめ

    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(AppCopy.homeWeeklySummary(appState.currentLanguage))
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            HStack(alignment: .top, spacing: AppSpacing.sm) {
                HomeMiniStatCard(
                    emoji: "🍵",
                    title: AppCopy.homeStatRestDays(appState.currentLanguage),
                    value: "\(viewModel.restDaysThisWeek)\(AppCopy.dayCountSuffix(appState.currentLanguage))",
                    language: appState.currentLanguage,
                    background: AppColors.mintLight
                )
                HomeMiniStatCard(
                    emoji: "🔥",
                    title: AppCopy.homeStatStreak(appState.currentLanguage),
                    value: "\(viewModel.streakDays)\(AppCopy.dayCountSuffix(appState.currentLanguage))",
                    language: appState.currentLanguage,
                    background: AppColors.yellowLight
                )
                HomeMiniStatCard(
                    emoji: "📊",
                    title: AppCopy.homeStatWeekTotal(appState.currentLanguage),
                    value: weekTotalText,
                    language: appState.currentLanguage,
                    background: AppColors.coralLight
                )
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.coralRed)
    }

    private var weekTotalText: String {
        let g = viewModel.weeklyConsumed
        if g == floor(g) {
            return "\(Int(g))g"
        }
        return String(format: "%.1fg", g)
    }

    // MARK: - 今日のドリンク

    private var todayDrinksSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(AppCopy.homeTodayDrinks(appState.currentLanguage))
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            if viewModel.todaysDrinkRecords.isEmpty {
                Text(AppCopy.homeNoDrinksYet(appState.currentLanguage))
                    .font(AppFonts.body(for: appState.currentLanguage, size: 15))
                    .foregroundStyle(AppColors.greyText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.todaysDrinkRecords, id: \.id) { record in
                            drinkPill(record)
                        }
                    }
                }
                .frame(height: drinkPillRowHeight)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.coralRed)
    }

    private func drinkPill(_ record: DrinkRecord) -> some View {
        let label = DrinkType.shortLabel(forRawType: record.drinkType, language: appState.currentLanguage)
        let emoji = DrinkType(rawValue: record.drinkType)?.emoji ?? "🍺"
        let grams = Int(round(record.pureAlcoholGrams))
        return Text("\(emoji) \(label) \(grams)g")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(AppColors.charcoal)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColors.coralLight)
            .clipShape(Capsule())
    }
}

// MARK: - ミニ Stat（今週のまとめ内）

private struct HomeMiniStatCard: View {
    let emoji: String
    let title: String
    let value: String
    let language: SupportedLanguage
    let background: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(emoji)
                .font(.system(size: 22))
            Text(title)
                .font(AppFonts.sublabel(for: language, size: 12))
                .foregroundStyle(AppColors.greyText)
            Text(value)
                .font(AppFonts.statCardValue())
                .foregroundStyle(AppColors.charcoal)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .modelContainer(for: [DrinkRecord.self, UserProfile.self], inMemory: true)
}
