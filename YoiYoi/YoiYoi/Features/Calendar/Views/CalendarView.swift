import SwiftData
import SwiftUI

/// DESIGN.md「カレンダー画面」— mint ウェーブヒーロー + 月グリッド + 今週の推移。
struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = CalendarViewModel()
    @State private var records: [DrinkRecord] = []
    @State private var dailyGoal: Double = 40

    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight() }

    /// `HomeView` と同型。ヒーローを `ScrollView` の外に置き、タブシェル＋`safeAreaInset` 下でも潰れにくくする。
    var body: some View {
        VStack(spacing: 0) {
            WaveHeroView(height: heroHeight, gradient: AppGradients.heroCalendar) {
                VStack(spacing: AppSpacing.md) {
                    Text("📅 カレンダー")
                        .font(AppFonts.heroTitle())
                        .foregroundStyle(AppColors.pureWhite)

                    Text("\(viewModel.monthTitleString(for: viewModel.visibleMonth))のまとめ")
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
        .onAppear { reload() }
        .onChange(of: scenePhase) { _, new in
            if new == .active { reload() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .drinkLogSheetDismissed)) { _ in
            reload()
        }
    }

    private var heroBadgesRow: some View {
        let counts = viewModel.monthSummaryCounts(
            records: records,
            dailyGoal: dailyGoal,
            today: Date()
        )
        return HStack(spacing: AppSpacing.md) {
            heroBadge(emoji: "🍵", value: "\(counts.rest)日", label: "休肝日")
            heroBadge(emoji: "✅", value: "\(counts.inGoal)日", label: "目標内")
            heroBadge(emoji: "⚠️", value: "\(counts.over)日", label: "超過")
        }
        .padding(.bottom, AppSpacing.sm)
    }

    private func heroBadge(emoji: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(emoji) \(value)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.pureWhite)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.pureWhite.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.pureWhite.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var monthCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(viewModel.monthTitleString(for: viewModel.visibleMonth))
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
                .accessibilityLabel("前の月")
                Button {
                    viewModel.shiftMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.charcoal)
                }
                .accessibilityLabel("次の月")
            }

            weekdayHeader

            let cells = viewModel.monthCells(records: records, dailyGoal: dailyGoal, today: Date())
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                    if cell.isPlaceholder {
                        Color.clear.frame(width: 44, height: 44)
                    } else if let _ = cell.date {
                        DayCellView(dayNumber: cell.dayNumber, visual: cell.visual, isToday: cell.isToday)
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
            ForEach(["月", "火", "水", "木", "金", "土", "日"], id: \.self) { w in
                Text(w)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.greyText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var weekChartCard: some View {
        let bars = viewModel.weekBarData(records: records, dailyGoal: dailyGoal, reference: Date())
        let scaleMax = Swift.max(bars.map(\.grams).max() ?? 0, dailyGoal, 1)

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("今週の推移")
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            HStack(alignment: .top, spacing: 0) {
                Text("\(Int(dailyGoal))g")
                    .font(AppFonts.sublabel(for: .ja, size: 10))
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
                            .fill(item.over ? AppColors.warmCoral : AppColors.mintGreen)
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
        return Swift.max(4, Swift.min(h, 72))
    }

    private func reload() {
        let desc = FetchDescriptor<DrinkRecord>()
        records = (try? modelContext.fetch(desc)) ?? []
        let profiles = (try? modelContext.fetch(FetchDescriptor<UserProfile>())) ?? []
        dailyGoal = profiles.first?.dailyGoalGrams ?? 40
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [DrinkRecord.self, UserProfile.self], inMemory: true)
}
