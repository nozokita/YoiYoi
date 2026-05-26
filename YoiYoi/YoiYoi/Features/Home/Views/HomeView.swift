import SwiftData
import SwiftUI

/// DESIGN.md「ホーム画面」— ウェーブヒーロー + ローカルの振り返りカード群。
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState

    @State private var viewModel = HomeViewModel()
    @State private var presentedSession: DrinkingSession?
    @State private var showFavoriteManager = false
    @State private var undoRecord: DrinkRecord?
    @State private var undoTask: Task<Void, Never>?

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
                    coachSection
                    quickRecordSection
                    sessionSection
                    weeklySummarySection
                    todayDrinksSection
                    if undoRecord != nil {
                        undoBanner
                    }
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
        .onReceive(NotificationCenter.default.publisher(for: .sessionDidChange)) { _ in
            viewModel.refresh(modelContext: modelContext)
        }
        .sheet(isPresented: $showFavoriteManager, onDismiss: {
            viewModel.refresh(modelContext: modelContext)
        }) {
            QuickDrinkManagerView()
                .environmentObject(appState)
        }
        .fullScreenCover(item: $presentedSession, onDismiss: {
            viewModel.refresh(modelContext: modelContext)
        }) { session in
            ActiveSessionView(session: session)
                .environmentObject(appState)
        }
    }

    private var coachSection: some View {
        AICoachBubbleView(
            context: LocalCoachContext(
                todayConsumed: viewModel.todayConsumed,
                dailyGoal: viewModel.dailyGoal,
                isSessionActive: viewModel.activeSession != nil,
                hydrationCount: viewModel.activeSession?.hydrationCount ?? 0
            ),
            personality: viewModel.coachPersonality,
            language: appState.currentLanguage
        )
    }

    private var quickRecordSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(AppCopy.homeQuickRecord(appState.currentLanguage))
                    .font(AppFonts.cardTitle())
                    .foregroundStyle(AppColors.charcoal)
                Spacer()
                if !viewModel.presets.isEmpty {
                    Button(AppCopy.homeManageFavorites(appState.currentLanguage)) {
                        showFavoriteManager = true
                    }
                    .font(AppFonts.sublabel(for: appState.currentLanguage, size: 13))
                    .foregroundStyle(AppColors.coralRed)
                }
            }

            Text(AppCopy.homeFavorites(appState.currentLanguage))
                .font(AppFonts.sublabel(for: appState.currentLanguage, size: 13))
                .foregroundStyle(AppColors.greyText)
            if viewModel.presets.isEmpty {
                Text(AppCopy.homeNoFavorites(appState.currentLanguage))
                    .font(AppFonts.body(for: appState.currentLanguage, size: 14))
                    .foregroundStyle(AppColors.greyText)
            } else {
                horizontalQuickRow {
                    ForEach(viewModel.presets, id: \.id) { preset in
                        quickButton(
                            type: preset.drinkType,
                            volume: preset.volumeML,
                            abv: preset.abvFraction,
                            drinks: preset.numberOfDrinks
                        )
                    }
                }
            }

            if !viewModel.recentRecords.isEmpty {
                Text(AppCopy.homeRecent(appState.currentLanguage))
                    .font(AppFonts.sublabel(for: appState.currentLanguage, size: 13))
                    .foregroundStyle(AppColors.greyText)
                horizontalQuickRow {
                    ForEach(viewModel.recentRecords, id: \.id) { record in
                        quickButton(
                            type: record.drinkType,
                            volume: record.volumeML,
                            abv: record.abvFraction,
                            drinks: record.numberOfDrinks
                        )
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.coralRed)
    }

    private func horizontalQuickRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                content()
            }
        }
    }

    private func quickButton(type: String, volume: Double, abv: Double, drinks: Int) -> some View {
        let label = DrinkType.shortLabel(forRawType: type, language: appState.currentLanguage)
        let emoji = DrinkType(rawValue: type)?.emoji ?? "🍺"
        return Button {
            saveQuickRecord(type: type, volume: volume, abv: abv, drinks: drinks)
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(emoji) \(label)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text("\(Int(volume))ml ×\(drinks)")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(AppColors.greyText)
            }
            .foregroundStyle(AppColors.charcoal)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColors.coralLight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var sessionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(AppCopy.homeSessionTitle(appState.currentLanguage))
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)
            Button {
                openOrStartSession()
            } label: {
                Text(
                    viewModel.activeSession == nil
                        ? AppCopy.homeSessionStart(appState.currentLanguage)
                        : AppCopy.homeSessionResume(appState.currentLanguage)
                )
                .font(AppFonts.body(for: appState.currentLanguage, size: 16))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.md)
                .background(AppColors.mintGreen)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.mintGreen)
    }

    private var undoBanner: some View {
        HStack {
            Text(AppCopy.homeLoggedUndo(appState.currentLanguage))
                .font(AppFonts.body(for: appState.currentLanguage, size: 14))
            Spacer()
            Button(AppCopy.homeUndo(appState.currentLanguage)) {
                undoQuickRecord()
            }
            .foregroundStyle(AppColors.coralRed)
            .fontWeight(.semibold)
        }
        .padding(AppSpacing.md)
        .background(AppColors.pureWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func saveQuickRecord(type: String, volume: Double, abv: Double, drinks: Int) {
        let record = QuickDrinkService.makeRecord(
            drinkType: type,
            volumeML: volume,
            abvFraction: abv,
            numberOfDrinks: drinks,
            sessionID: viewModel.activeSession?.id
        )
        modelContext.insert(record)
        guard (try? modelContext.save()) != nil else { return }
        undoTask?.cancel()
        undoRecord = record
        undoTask = Task {
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }
            undoRecord = nil
        }
        viewModel.refresh(modelContext: modelContext)
        NotificationCenter.default.post(name: .drinkLogSheetDismissed, object: nil)
    }

    private func undoQuickRecord() {
        guard let record = undoRecord else { return }
        undoTask?.cancel()
        modelContext.delete(record)
        try? modelContext.save()
        undoRecord = nil
        viewModel.refresh(modelContext: modelContext)
        NotificationCenter.default.post(name: .drinkLogSheetDismissed, object: nil)
    }

    private func openOrStartSession() {
        if let active = viewModel.activeSession {
            presentedSession = active
            return
        }
        let session = DrinkingSession()
        modelContext.insert(session)
        try? modelContext.save()
        Task {
            await NotificationService.scheduleHydrationReminders(
                sessionID: session.id,
                startingAt: session.startTime,
                intervalMinutes: viewModel.hydrationIntervalMinutes,
                language: appState.currentLanguage
            )
        }
        presentedSession = session
        viewModel.refresh(modelContext: modelContext)
        NotificationCenter.default.post(name: .sessionDidChange, object: nil)
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
        .modelContainer(for: [DrinkRecord.self, UserProfile.self, DrinkingSession.self, QuickDrinkPreset.self], inMemory: true)
}
