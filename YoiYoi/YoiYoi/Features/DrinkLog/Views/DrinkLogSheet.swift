import SwiftData
import SwiftUI

/// DESIGN.md「飲酒記録シート」— グリッド・調整カード・純AL 表示・保存 + `FeedGenerator`（ローカル生成のみ）。
struct DrinkLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var viewModel = DrinkLogViewModel()
    @State private var saveError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("🍺 のみものを記録")
                        .font(AppFonts.screenTitle())
                        .foregroundStyle(AppColors.charcoal)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        DrinkGridView(selection: $viewModel.selectedType)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.pureWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .themedShadow(themeColor: AppColors.coralRed, opacity: 0.10, radius: 16, y: 6)

                    adjustmentCard

                    PuffyButton(title: "🍺 記録する！", isEnabled: viewModel.canSave) {
                        saveRecord()
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(
                LinearGradient(
                    colors: [AppColors.pureWhite, AppColors.cream],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
        .alert("保存できませんでした", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveError ?? "")
        }
    }

    private var adjustmentCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("調整")
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            stepperRow(title: "杯数", value: "\(viewModel.numberOfDrinks)", decrement: viewModel.decrementDrinks, increment: viewModel.incrementDrinks)

            stepperRow(
                title: "度数(%)",
                value: String(format: "%.1f", viewModel.abvPercent),
                decrement: viewModel.decrementAbv,
                increment: viewModel.incrementAbv
            )

            Divider().background(AppColors.greyText.opacity(0.25))

            VStack(spacing: AppSpacing.xs) {
                Text("純アルコール量")
                    .font(AppFonts.sublabel(for: appState.currentLanguage, size: 13))
                    .foregroundStyle(AppColors.greyText)
                Text(String(format: "%.1fg", viewModel.pureAlcoholGrams))
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.coralRed)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.coralRed)
    }

    private func stepperRow(title: String, value: String, decrement: @escaping () -> Void, increment: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(AppFonts.body(for: appState.currentLanguage, size: 16))
                .foregroundStyle(AppColors.charcoal)
            Spacer()
            Button("－", action: decrement)
                .font(.title3.bold())
                .foregroundStyle(AppColors.coralRed)
                .frame(minWidth: 44, minHeight: 44)
            Text(value)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.charcoal)
                .frame(minWidth: 52)
            Button("＋", action: increment)
                .font(.title3.bold())
                .foregroundStyle(AppColors.coralRed)
                .frame(minWidth: 44, minHeight: 44)
        }
    }

    private func saveRecord() {
        guard let type = viewModel.selectedType else { return }
        do {
            let record = DrinkRecord(
                drinkType: type.rawValue,
                volumeML: type.defaultVolumeML,
                abv: viewModel.abv,
                numberOfDrinks: viewModel.numberOfDrinks
            )
            modelContext.insert(record)
            try modelContext.save()

            let cal = Calendar.current
            let now = Date()
            let all = try modelContext.fetch(FetchDescriptor<DrinkRecord>())
            let profiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
            let profile = profiles.first

            let dailyGoal = profile?.dailyGoalGrams ?? 40
            let weeklyGoal = profile?.weeklyGoalGrams ?? 280
            let uid: String
            if let p = profile {
                uid = p.firebaseUID.isEmpty ? p.id.uuidString : p.firebaseUID
            } else {
                uid = "local"
            }

            let todayTotal = AlcoholCalculator.dailyTotal(gramsFrom: all, on: now, calendar: cal)
            let weekTotal = AlcoholCalculator.weeklyTotal(gramsFrom: all, inWeekOf: now, calendar: cal)
            let streak = AlcoholCalculator.streakDays(
                gramsFrom: all,
                dailyGoalGrams: dailyGoal,
                endingOn: now,
                calendar: cal
            )

            let startOfToday = cal.startOfDay(for: now)
            let drinkKeys: [String] = all
                .filter { cal.isDate($0.loggedAt, inSameDayAs: startOfToday) }
                .flatMap { r in Array(repeating: r.drinkType, count: r.numberOfDrinks) }

            let ctx = FeedGenerator.Context(
                referenceDate: now,
                uid: uid,
                language: appState.currentLanguage.rawValue,
                todayTotalGrams: todayTotal,
                dailyGoalGrams: dailyGoal,
                weeklyTotalGrams: weekTotal,
                weeklyGoalGrams: weeklyGoal,
                streakDays: streak,
                drinkTypesToday: drinkKeys
            )
            _ = FeedGenerator.generatePost(context: ctx, calendar: cal)

            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#Preview {
    DrinkLogSheet()
        .environment(AppState())
        .modelContainer(for: [DrinkRecord.self, UserProfile.self], inMemory: true)
}
