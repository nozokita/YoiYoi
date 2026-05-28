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
    @State private var editingRecord: DrinkRecord?
    @State private var undoRecord: DrinkRecord?
    @State private var undoTask: Task<Void, Never>?
    @State private var reloadTask: Task<Void, Never>?

    /// 縦 `ScrollView` 内の横 `ScrollView` は高さ未確定だと全体レイアウトが潰れて真っ白になることがある（`docs/DEBUG_WHITE_SCREEN.md`）。
    private var drinkPillRowHeight: CGFloat { 44 }

    /// 固定ヒーロー + 下段 `ScrollView` は、オンボーディング直後のルート差し替え時に高さ提案が崩れて
    /// 白画面になることがある。単一 `ScrollView` にカードを積み、初回描画を安定させる。
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                heroSection
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
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xxl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cream)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
        .accessibilityIdentifier("home.root")
        .sheet(isPresented: $showFavoriteManager) {
            QuickDrinkManagerView()
                .environmentObject(appState)
        }
        .sheet(isPresented: Binding(
            get: { editingRecord != nil },
            set: { if !$0 { editingRecord = nil } }
        ), onDismiss: {
            scheduleReloadFromStore()
        }) {
            if let editingRecord {
                DrinkLogSheet(editingRecord: editingRecord)
                    .environmentObject(appState)
                    .presentationDetents([.large])
            }
        }
        .fullScreenCover(item: $presentedSession) { session in
            ActiveSessionView(session: session)
                .environmentObject(appState)
        }
        .onAppear(perform: scheduleReloadFromStore)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                scheduleReloadFromStore()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .drinkLogSheetDismissed)) { _ in
            scheduleReloadFromStore()
        }
        .onReceive(NotificationCenter.default.publisher(for: .userProfileDidChange)) { _ in
            scheduleReloadFromStore()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionDidChange)) { _ in
            scheduleReloadFromStore()
        }
    }

    private var heroSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text(AppCopy.homePureAlcoholLabel(appState.currentLanguage))
                .font(AppFonts.heroTitle())
                .foregroundStyle(AppColors.pureWhite)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("home.heroTitle")

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
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppGradients.heroHome)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var coachSection: some View {
        AICoachBubbleView(
            context: LocalCoachContext(
                todayConsumed: viewModel.todayConsumed,
                dailyGoal: viewModel.dailyGoal,
                isSessionActive: viewModel.activeSession != nil,
                hydrationCount: viewModel.activeSession?.hydrationCount ?? 0,
                weeklyConsumed: viewModel.weeklyConsumed,
                weeklyGoal: viewModel.weeklyGoal,
                yesterdayConsumed: viewModel.yesterdayConsumed,
                steadyDrinkRawType: viewModel.coachDrinkTrend.steadyRawType,
                steadyDrinkAverageGrams: viewModel.coachDrinkTrend.steadyAverageGrams,
                riskyDrinkRawType: viewModel.coachDrinkTrend.riskyRawType,
                riskyDrinkAverageGrams: viewModel.coachDrinkTrend.riskyAverageGrams,
                todaysRecordCount: viewModel.coachBehavior.todaysRecordCount,
                latestDrinkGrams: viewModel.coachBehavior.latestDrinkGrams,
                minutesSinceLastDrink: viewModel.coachBehavior.minutesSinceLastDrink,
                recentLogGapMinutes: viewModel.coachBehavior.recentLogGapMinutes,
                loggingStreakDays: viewModel.coachBehavior.loggingStreakDays,
                plannedDrinkRawType: viewModel.coachBehavior.plannedDrinkRawType,
                plannedDrinkCount: viewModel.coachBehavior.plannedDrinkCount,
                plannedDrinkVolumeML: viewModel.coachBehavior.plannedDrinkVolumeML,
                riskyWeekday: viewModel.coachBehavior.riskyWeekday,
                riskyTimeSlot: viewModel.coachBehavior.riskyTimeSlot
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
        let drinkType = DrinkType(rawValue: type)
        return Button {
            saveQuickRecord(type: type, volume: volume, abv: abv, drinks: drinks)
        } label: {
            HStack(spacing: AppSpacing.sm) {
                SVGIcon(icon: drinkType?.icon ?? .drinkBeer, size: 20, color: AppColors.coralRed)
                    .frame(width: 34, height: 34)
                    .background(AppColors.pureWhite.opacity(0.8))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    Text("\(Int(volume))ml ×\(drinks)")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(AppColors.greyText)
                }
            }
            .foregroundStyle(AppColors.charcoal)
            .padding(.leading, AppSpacing.sm)
            .padding(.trailing, AppSpacing.md)
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
        viewModel.applyQuickRecord(record)
        NotificationCenter.default.post(name: .drinkLogSheetDismissed, object: nil)
    }

    private func undoQuickRecord() {
        guard let record = undoRecord else { return }
        undoTask?.cancel()
        modelContext.delete(record)
        try? modelContext.save()
        undoRecord = nil
        viewModel.removeQuickRecord(record)
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
        viewModel.setActiveSession(session)
        NotificationCenter.default.post(name: .sessionDidChange, object: nil)
    }

    private func scheduleReloadFromStore() {
        reloadTask?.cancel()
        reloadTask = Task { @MainActor in
            await Task.yield()
            guard !Task.isCancelled else { return }
            reloadFromStore()
        }
    }

    private func reloadFromStore() {
        let recordDescriptor = FetchDescriptor<DrinkRecord>(
            sortBy: [SortDescriptor(\.loggedAt, order: .reverse)]
        )
        let presetDescriptor = FetchDescriptor<QuickDrinkPreset>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        let sessionDescriptor = FetchDescriptor<DrinkingSession>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        viewModel.refresh(
            records: (try? modelContext.fetch(recordDescriptor)) ?? [],
            profiles: (try? modelContext.fetch(FetchDescriptor<UserProfile>())) ?? [],
            presets: (try? modelContext.fetch(presetDescriptor)) ?? [],
            sessions: (try? modelContext.fetch(sessionDescriptor)) ?? []
        )
    }

    // MARK: - 今週のまとめ

    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(AppCopy.homeWeeklySummary(appState.currentLanguage))
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            HStack(alignment: .top, spacing: AppSpacing.sm) {
                HomeMiniStatCard(
                    icon: .rest,
                    title: AppCopy.homeStatRestDays(appState.currentLanguage),
                    value: "\(viewModel.restDaysThisWeek)\(AppCopy.dayCountSuffix(appState.currentLanguage))",
                    language: appState.currentLanguage,
                    background: AppColors.mintLight
                )
                HomeMiniStatCard(
                    icon: .streak,
                    title: AppCopy.homeStatStreak(appState.currentLanguage),
                    value: "\(viewModel.streakDays)\(AppCopy.dayCountSuffix(appState.currentLanguage))",
                    language: appState.currentLanguage,
                    background: AppColors.yellowLight
                )
                HomeMiniStatCard(
                    icon: .chart,
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
        let drinkType = DrinkType(rawValue: record.drinkType)
        let grams = Int(round(record.pureAlcoholGrams))
        return Button {
            editingRecord = record
        } label: {
            HStack(spacing: AppSpacing.xs) {
                SVGIcon(icon: drinkType?.icon ?? .drinkBeer, size: 15, color: AppColors.coralRed)
                Text("\(label) \(grams)g")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.charcoal)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColors.coralLight)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ミニ Stat（今週のまとめ内）

private struct HomeMiniStatCard: View {
    let icon: YoiYoiIcon
    let title: String
    let value: String
    let language: SupportedLanguage
    let background: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            SVGIcon(icon: icon, size: 22, color: AppColors.charcoal.opacity(0.78))
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
