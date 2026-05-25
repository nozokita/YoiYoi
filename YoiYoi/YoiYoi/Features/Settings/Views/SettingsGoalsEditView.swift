import SwiftData
import SwiftUI

/// 設定から `UserProfile` の日次・週次目標を編集。
struct SettingsGoalsEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var dailyGoal: Double = 40
    @State private var weeklyGoal: Double = 280

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text(AppCopy.settingsGoalsHint(appState.currentLanguage))
                        .font(AppFonts.body(for: appState.currentLanguage, size: 15))
                        .foregroundStyle(AppColors.greyText)

                    goalStepper(
                        title: AppCopy.settingsDailyGoalGrams(appState.currentLanguage),
                        value: Int(dailyGoal),
                        decrement: { adjustDaily(by: -5) },
                        increment: { adjustDaily(by: 5) }
                    )
                    goalStepper(
                        title: AppCopy.settingsWeeklyGoalGrams(appState.currentLanguage),
                        value: Int(weeklyGoal),
                        decrement: { adjustWeekly(by: -35) },
                        increment: { adjustWeekly(by: 35) }
                    )
                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(AppColors.cream)
            .navigationTitle(AppCopy.settingsGoalsTitle(appState.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppCopy.settingsCancel(appState.currentLanguage)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppCopy.settingsSave(appState.currentLanguage)) {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear { loadFromProfile() }
    }

    private func loadFromProfile() {
        let desc = FetchDescriptor<UserProfile>()
        guard let p = try? modelContext.fetch(desc).first else { return }
        dailyGoal = p.dailyGoalGrams
        weeklyGoal = p.weeklyGoalGrams
    }

    private func adjustDaily(by delta: Double) {
        dailyGoal = (dailyGoal + delta).clamped(to: 5...120)
    }

    private func adjustWeekly(by delta: Double) {
        weeklyGoal = (weeklyGoal + delta).clamped(to: 35...980)
    }

    private func save() {
        let desc = FetchDescriptor<UserProfile>()
        guard let p = try? modelContext.fetch(desc).first else { return }
        p.dailyGoalGrams = dailyGoal
        p.weeklyGoalGrams = weeklyGoal
        try? modelContext.save()
        NotificationCenter.default.post(name: .userProfileDidChange, object: nil)
    }

    private func goalStepper(
        title: String,
        value: Int,
        decrement: @escaping () -> Void,
        increment: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(title)
                .font(AppFonts.body(for: appState.currentLanguage, size: 16))
                .foregroundStyle(AppColors.charcoal)
            Spacer()
            Button("−", action: decrement)
                .font(.title3.bold())
                .foregroundStyle(AppColors.coralRed)
                .frame(minWidth: 44, minHeight: 44)
            Text("\(value)")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.charcoal)
                .frame(minWidth: 48)
            Button("+", action: increment)
                .font(.title3.bold())
                .foregroundStyle(AppColors.coralRed)
                .frame(minWidth: 44, minHeight: 44)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.lavender)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    SettingsGoalsEditView()
        .environmentObject(AppState())
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
