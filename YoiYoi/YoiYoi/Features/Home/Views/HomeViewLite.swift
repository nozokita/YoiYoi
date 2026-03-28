import SwiftData
import SwiftUI

/// 白画面切り分け用の段階的 HomeView。依存を 1 つずつ足して、どこで壊れるか特定する。
/// Step 2: EnvironmentObject（言語表示まで）。
/// Step 3: SwiftData（最小 fetch 件数表示）まで追加していく。
/// Step 4: ScrollView + 静的カード（Text のみ）を追加する。
/// Step 5: `WaveHeroView`（グラデ＋`WaveShape` クリップ）。
/// Step 6: ヒーロー内に `AlcoholMeterView`（SwiftData の今日合計＋目標）。
/// Step 7-1: 下段カード1枚目だけ「今週のまとめ（週合計）」を最小導入。
/// Step 7-2: 下段カード2枚目だけ「今日のドリンク件数」を最小導入。
/// Step 7-3: 下段カード3枚目だけ「みんなの様子（準備中）」へ最小導入。
/// 週まとめカードは **週合計の単行のみ**（複行・WaveShape 等で白画面が出たため当面これに戻す）。
/// Step Next-A: 「今日のドリンク」は件数0のときだけ空状態の2行文言へ（`HStack`・横Scroll・WaveShapeは触らない）。
/// Step Next-B: 1件以上のとき **最新から最大3件**を改行テキストで列挙（4件目以降は「…他N件」。ピル・横Scrollはまだ入れない）。
/// Step Next-C: `ContentView` から本物の `DrinkLogSheet` を開き、閉じたあと `drinkLogSheetDismissed` で再読込。
/// Step Next-D: 画面上の **Step 2〜6 診断テキスト**を削除（レイアウトはカード＋記録ボタンのまま）。
/// Step Next-E: ヒーローを `HomeView` に寄せる（ニックネーム行・挨拶・メーター・状態テキスト、`UserProfile` 参照）。
///
/// **白画面対策**: ヒーローを **縦 `ScrollView` の内側**に置くとタブシェル環境でレイアウトが潰れることがあるため、
/// **`VStack` で固定高ヒーロー + 下段だけ `ScrollView`** とする。
struct HomeViewLite: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var todaysDrinkCount: Int = 0
    /// `onAppear` でだけ更新。本文は改行区切り（`HStack` なしで `HomeView` のピルに寄せるための中間段階）。
    @State private var todayDrinksListSnippet: String = ""
    @State private var todayConsumed: Double = 0
    @State private var weeklyConsumed: Double = 0
    @State private var dailyGoalGrams: Double = 40
    /// `HomeView` と同形式。プロフィールが無いときは短いプレースホルダ。
    @State private var nicknameLine: String = ""

    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight() }

    /// `HomeViewModel.meterSubtext(language:)` と同じ分岐（Lite は ViewModel を増やさずローカルに保持）。
    private var heroMeterSubtext: String {
        let p = AlcoholCalculator.percentage(consumed: todayConsumed, goal: dailyGoalGrams)
        switch appState.currentLanguage {
        case .ja:
            if p >= 100 { return "今日はオーバー…でも大丈夫！" }
            if p >= 80 { return "そろそろ気をつけて！" }
            let remaining = Int(AlcoholCalculator.remainingToday(consumed: todayConsumed, dailyGoal: dailyGoalGrams))
            return "あと \(remaining)g 飲めるよ！"
        case .en:
            if p >= 100 { return "Past today's goal—you're OK!" }
            if p >= 80 { return "Easy does it—you're close to the limit." }
            let remaining = Int(AlcoholCalculator.remainingToday(consumed: todayConsumed, dailyGoal: dailyGoalGrams))
            return "About \(remaining)g left today."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            WaveHeroView(height: heroHeight, gradient: AppGradients.heroHome) {
                VStack(spacing: AppSpacing.md) {
                    Text(nicknameLine)
                        .font(AppFonts.heroSubtitle())
                        .foregroundStyle(AppColors.pureWhite.opacity(0.85))
                        .multilineTextAlignment(.center)

                    Text(AppCopy.homeGreeting(appState.currentLanguage))
                        .font(AppFonts.heroTitle())
                        .foregroundStyle(AppColors.pureWhite)
                        .multilineTextAlignment(.center)

                    AlcoholMeterView(consumed: todayConsumed, dailyGoal: dailyGoalGrams)

                    Text(heroMeterSubtext)
                        .font(AppFonts.heroSubtitle())
                        .foregroundStyle(AppColors.pureWhite.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.sm)
                }
                .padding(.bottom, AppSpacing.lg)
            }
            .frame(height: heroHeight)
            .frame(maxWidth: .infinity)

            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        TextCard(title: AppCopy.homeWeeklySummary(appState.currentLanguage), content: "\(AppCopy.liteWeekTotalLabel(appState.currentLanguage)): \(weeklyConsumedText)")
                        TextCard(title: AppCopy.homeTodayDrinks(appState.currentLanguage), content: todayDrinksCardBody)
                        TextCard(title: AppCopy.homeFeedPreview(appState.currentLanguage), content: AppCopy.liteFeedPlaceholder(appState.currentLanguage))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, AppSpacing.lg)

                    Button {
                        NotificationCenter.default.post(name: .openDrinkLogSheet, object: nil)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text(AppCopy.liteLogButton(appState.currentLanguage))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(AppColors.coralRed)
                        .background(AppColors.coralLight)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
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
            AppLaunchDiagnostics.log("HomeViewLite.onAppear (Next-E: hero copy aligned with HomeView)")
            reloadFromStore()
        }
        .onReceive(NotificationCenter.default.publisher(for: .drinkLogSheetDismissed)) { _ in
            DispatchQueue.main.async {
                reloadFromStore()
            }
        }
        .onChange(of: appState.currentLanguage) { _, _ in
            reloadFromStore()
        }
    }

    private func reloadFromStore() {
        let calendar = Calendar.current
        let now = Date()

        let drinkDescriptor = FetchDescriptor<DrinkRecord>()
        let drinks = (try? modelContext.fetch(drinkDescriptor)) ?? []
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profiles = (try? modelContext.fetch(profileDescriptor)) ?? []

        let startOfToday = calendar.startOfDay(for: now)
        let todaysDrinks = drinks
            .filter { calendar.isDate($0.loggedAt, inSameDayAs: startOfToday) }
            .sorted { $0.loggedAt > $1.loggedAt }
        todaysDrinkCount = todaysDrinks.count
        if todaysDrinks.isEmpty {
            todayDrinksListSnippet = ""
        } else {
            let lines = todaysDrinks.prefix(3).map { Self.drinkLine(for: $0, language: appState.currentLanguage) }
            var snippet = lines.joined(separator: "\n")
            if todaysDrinks.count > 3 {
                snippet += "\n\(AppCopy.liteMoreCount(todaysDrinks.count - 3, appState.currentLanguage))"
            }
            todayDrinksListSnippet = snippet
        }

        if let p = profiles.first {
            dailyGoalGrams = p.dailyGoalGrams
            switch appState.currentLanguage {
            case .ja:
                nicknameLine = "\(p.nicknameFlag)\(p.nicknameEmoji) \(p.nicknameAdjective)\(p.nicknameNoun) さん"
            case .en:
                nicknameLine = "\(p.nicknameFlag)\(p.nicknameEmoji) \(p.nicknameAdjective)\(p.nicknameNoun)"
            }
        } else {
            dailyGoalGrams = 40
            nicknameLine = AppCopy.homeNicknameFallback(appState.currentLanguage)
        }
        todayConsumed = AlcoholCalculator.dailyTotal(gramsFrom: drinks, on: now, calendar: calendar)
        weeklyConsumed = AlcoholCalculator.weeklyTotal(gramsFrom: drinks, inWeekOf: now, calendar: calendar)
    }

    private var weeklyConsumedText: String {
        if weeklyConsumed == floor(weeklyConsumed) {
            return "\(Int(weeklyConsumed))g"
        }
        return String(format: "%.1fg", weeklyConsumed)
    }

    private var todayDrinksCardBody: String {
        let lang = appState.currentLanguage
        if todaysDrinkCount == 0 {
            return AppCopy.homeNoDrinksYet(lang)
        }
        if todayDrinksListSnippet.isEmpty {
            return AppCopy.liteTodayRecordsLine(todaysDrinkCount, lang)
        }
        return "\(AppCopy.liteTodayRecordsLine(todaysDrinkCount, lang))\n\(todayDrinksListSnippet)"
    }

    private static func drinkLine(for record: DrinkRecord, language: SupportedLanguage) -> String {
        let label = DrinkType.shortLabel(forRawType: record.drinkType, language: language)
        let emoji = DrinkType(rawValue: record.drinkType)?.emoji ?? "🍺"
        let grams = Int(round(record.pureAlcoholGrams))
        return "\(emoji) \(label) \(grams)g"
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
                    .multilineTextAlignment(.leading)
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
