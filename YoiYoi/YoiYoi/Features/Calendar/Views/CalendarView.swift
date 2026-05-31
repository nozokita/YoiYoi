import SwiftData
import SwiftUI

/// DESIGN.md「カレンダー画面」— mint ウェーブヒーロー + 月グリッド + 今週の推移。
struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState
    @State private var viewModel = CalendarViewModel()
    @State private var records: [DrinkRecord] = []
    @State private var sessions: [DrinkingSession] = []
    @State private var dailyGoal: Double = 40
    @State private var trackingStartDate: Date?

    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight() }

    private var visibleMonthTitle: String {
        viewModel.monthTitleString(for: viewModel.visibleMonth, language: appState.currentLanguage)
    }

    /// `HomeView` と同型。ヒーローを `ScrollView` の外に置き、タブシェル＋`safeAreaInset` 下でも潰れにくくする。
    var body: some View {
        VStack(spacing: 0) {
            WaveHeroView(height: heroHeight, gradient: AppGradients.heroCalendar) {
                VStack(spacing: AppSpacing.md) {
                    Text(AppCopy.calendarHeroTitle(appState.currentLanguage))
                        .font(AppFonts.heroTitle())
                        .foregroundStyle(AppColors.pureWhite)

                    Text(AppCopy.calendarMonthBlurb(visibleMonthTitle, appState.currentLanguage))
                        .font(AppFonts.heroSubtitle())
                        .foregroundStyle(AppColors.pureWhite.opacity(0.85))

                    heroBadgesRow
                }
                .padding(.bottom, AppSpacing.lg)
            }
            .frame(height: heroHeight)
            .frame(maxWidth: .infinity)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    monthCard
                    weekChartCard
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, -AppSpacing.lg)
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
            TelemetryService.track(.screenViewed, screen: .calendar, modelContext: modelContext)
            reload()
        }
        .onChange(of: scenePhase) { _, new in
            if new == .active { reload() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .drinkLogSheetDismissed)) { _ in
            reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: .userProfileDidChange)) { _ in
            reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionDidChange)) { _ in
            reload()
        }
    }

    private var heroBadgesRow: some View {
        let counts = viewModel.monthSummaryCounts(
            records: records,
            dailyGoal: dailyGoal,
            trackingStartDate: trackingStartDate,
            today: Date()
        )
        let suf = AppCopy.dayCountSuffix(appState.currentLanguage)
        return HStack(spacing: AppSpacing.md) {
            heroBadge(icon: .rest, value: "\(counts.rest)\(suf)", label: AppCopy.calendarStatRest(appState.currentLanguage))
            heroBadge(icon: .check, value: "\(counts.inGoal)\(suf)", label: AppCopy.calendarStatInGoal(appState.currentLanguage))
            heroBadge(icon: .alert, value: "\(counts.over)\(suf)", label: AppCopy.calendarStatOver(appState.currentLanguage))
        }
        .padding(.bottom, AppSpacing.sm)
    }

    private func heroBadge(icon: YoiYoiIcon, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: AppSpacing.xs) {
                SVGIcon(icon: icon, size: 18, color: AppColors.pureWhite)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.pureWhite)
            }
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.pureWhite.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.pureWhite.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.pureWhite.opacity(0.16), lineWidth: 1)
        }
    }

    private var monthCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(visibleMonthTitle)
                    .font(AppFonts.cardTitle())
                    .foregroundStyle(AppColors.charcoal)
                Spacer()
                Button {
                    viewModel.shiftMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.charcoal)
                }
                .accessibilityLabel(AppCopy.calendarPrevMonthA11y(appState.currentLanguage))
                Button {
                    viewModel.shiftMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.charcoal)
                }
                .accessibilityLabel(AppCopy.calendarNextMonthA11y(appState.currentLanguage))
            }

            weekdayHeader

            let cells = viewModel.monthCells(
                records: records,
                sessions: sessions,
                dailyGoal: dailyGoal,
                trackingStartDate: trackingStartDate,
                today: Date()
            )
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                    if cell.isPlaceholder {
                        Color.clear.frame(width: 44, height: 44)
                    } else if let _ = cell.date {
                        DayCellView(
                            dayNumber: cell.dayNumber,
                            visual: cell.visual,
                            isToday: cell.isToday,
                            achievedLastOrder: cell.achievedLastOrder,
                            achievementLabel: AppCopy.calendarLastOrderAchievement(appState.currentLanguage)
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.mintGreen)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 6) {
            ForEach(AppCopy.weekdayInitials(appState.currentLanguage), id: \.self) { w in
                Text(w)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.greyText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var weekChartCard: some View {
        let bars = viewModel.weekBarData(
            records: records,
            dailyGoal: dailyGoal,
            reference: Date(),
            language: appState.currentLanguage
        )
        let scaleMax = Swift.max(bars.map(\.grams).max() ?? 0, dailyGoal, 1)

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(AppCopy.calendarWeekTrend(appState.currentLanguage))
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            HStack(alignment: .top, spacing: 0) {
                Text("\(Int(dailyGoal))g")
                    .font(AppFonts.sublabel(for: appState.currentLanguage, size: 10))
                    .foregroundStyle(AppColors.greyText.opacity(0.6))
                    .frame(width: 28, alignment: .trailing)

                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(AppColors.greyText.opacity(0.4))
                        .frame(height: 1)
                }
                .frame(maxWidth: .infinity)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(bars.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(item.over ? AppColors.warmCoral : AppColors.successDeep)
                            .frame(width: 32, height: barHeight(grams: item.grams, scaleMax: scaleMax))
                        Text(item.label)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.greyText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120, alignment: .bottom)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.mintGreen)
    }

    private func barHeight(grams: Double, scaleMax: Double) -> CGFloat {
        let cap = max(scaleMax, 1)
        let h = CGFloat(grams / cap) * 72
        return Swift.max(8, Swift.min(h, 72))
    }

    private func reload() {
        let desc = FetchDescriptor<DrinkRecord>()
        records = (try? modelContext.fetch(desc)) ?? []
        sessions = (try? modelContext.fetch(FetchDescriptor<DrinkingSession>())) ?? []
        let profiles = (try? modelContext.fetch(FetchDescriptor<UserProfile>())) ?? []
        dailyGoal = profiles.first?.dailyGoalGrams ?? 40
        trackingStartDate = [
            profiles.first?.createdAt,
            records.map(\.loggedAt).min(),
            sessions.map(\.startTime).min(),
        ]
        .compactMap(\.self)
        .min()
    }
}

#Preview {
    CalendarView()
        .environmentObject(AppState())
        .modelContainer(for: [DrinkRecord.self, UserProfile.self, DrinkingSession.self, QuickDrinkPreset.self, TelemetryEvent.self], inMemory: true)
}
