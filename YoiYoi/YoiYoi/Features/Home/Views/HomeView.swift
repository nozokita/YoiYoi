import SwiftData
import SwiftUI

/// DESIGN.md「ホーム画面」— ウェーブヒーロー + カード群（今週のまとめ / 今日のドリンク / みんなの様子プレースホルダー）。
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState

    @State private var viewModel = HomeViewModel()

    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight() }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                    WaveHeroView(height: heroHeight, gradient: AppGradients.heroHome) {
                        VStack(spacing: AppSpacing.md) {
                            Text(viewModel.nicknameLine)
                                .font(AppFonts.heroSubtitle())
                                .foregroundStyle(AppColors.pureWhite.opacity(0.85))
                                .multilineTextAlignment(.center)

                            Text("おつかれさま！🍺")
                                .font(AppFonts.heroTitle())
                                .foregroundStyle(AppColors.pureWhite)
                                .multilineTextAlignment(.center)

                            AlcoholMeterView(
                                consumed: viewModel.todayConsumed,
                                dailyGoal: viewModel.dailyGoal
                            )

                            Text(viewModel.meterSubtext)
                                .font(AppFonts.heroSubtitle())
                                .foregroundStyle(AppColors.pureWhite.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.sm)
                        }
                        .padding(.bottom, AppSpacing.lg)
                    }
                    .frame(height: heroHeight)

                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        weeklySummarySection
                        todayDrinksSection
                        feedPreviewSection
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, -AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xxl)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cream)
            }
        }
        .background(AppColors.cream)
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
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
    }

    // MARK: - 今週のまとめ

    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("今週のまとめ")
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            HStack(alignment: .top, spacing: AppSpacing.sm) {
                HomeMiniStatCard(
                    emoji: "🍵",
                    title: "休肝日",
                    value: "\(viewModel.restDaysThisWeek)日",
                    background: AppColors.mintLight
                )
                HomeMiniStatCard(
                    emoji: "🔥",
                    title: "連続",
                    value: "\(viewModel.streakDays)日",
                    background: AppColors.yellowLight
                )
                HomeMiniStatCard(
                    emoji: "📊",
                    title: "週合計",
                    value: weekTotalText,
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
            Text("今日のドリンク")
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            if viewModel.todaysDrinkRecords.isEmpty {
                Text("まだ記録がないよ。\n＋ボタンで記録してね！")
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
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.coralRed)
    }

    private func drinkPill(_ record: DrinkRecord) -> some View {
        let label = DrinkType.shortLabelJA(forRawType: record.drinkType)
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

    // MARK: - みんなの様子（Phase 8 までプレースホルダー）

    private var feedPreviewSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("みんなの様子")
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            FeedPreviewPlaceholderRow(
                flagEmoji: "🇺🇸",
                nickname: "⭐ ChillFox",
                message: "目標内！ビール×2で28g 🎉",
                reactions: "👏12  🔥8"
            )

            Rectangle()
                .fill(AppColors.greyText.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, AppSpacing.xs)

            FeedPreviewPlaceholderRow(
                flagEmoji: "🇯🇵",
                nickname: "🌸 のんびりパンダ",
                message: "休肝日！3日連続 🌿",
                reactions: "💪5  🫂3"
            )

            Text("もっと見る →")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.coralRed)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, AppSpacing.sm)
                .opacity(FeatureFlags.isFeedEnabled ? 1 : 0.45)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.coralRed)
    }
}

// MARK: - ミニ Stat（今週のまとめ内）

private struct HomeMiniStatCard: View {
    let emoji: String
    let title: String
    let value: String
    let background: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(emoji)
                .font(.system(size: 22))
            Text(title)
                .font(AppFonts.sublabel(for: .ja, size: 12))
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

// MARK: - フィードプレビュー行（ダミー）

private struct FeedPreviewPlaceholderRow: View {
    let flagEmoji: String
    let nickname: String
    let message: String
    let reactions: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("\(flagEmoji) \(nickname)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.charcoal)
            Text(message)
                .font(AppFonts.body(for: .ja, size: 14))
                .foregroundStyle(AppColors.greyText)
            Text(reactions)
                .font(AppFonts.sublabel(for: .ja, size: 13))
                .foregroundStyle(AppColors.greyText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .modelContainer(for: [DrinkRecord.self, UserProfile.self], inMemory: true)
}
