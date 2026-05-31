import SwiftData
import SwiftUI

struct ActiveSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    let session: DrinkingSession
    @State private var records: [DrinkRecord] = []
    @State private var profile = UserProfile()
    @State private var showDrinkLog = false
    @State private var showLastOrder = false
    @State private var praiseVisible = false

    private var sessionRecords: [DrinkRecord] { SessionManager.records(for: session.id, in: records) }
    private var sessionTotal: Double { SessionManager.pureAlcoholTotal(for: session.id, in: records) }
    private var personality: CoachPersonality {
        CoachPersonality(rawValue: profile.aiCoachPersonality) ?? .friendly
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        VStack(spacing: AppSpacing.xs) {
                            Text(AppCopy.sessionElapsed(appState.currentLanguage))
                                .font(AppFonts.sublabel(for: appState.currentLanguage, size: 13))
                            Text(SessionManager.elapsedText(from: session.startTime, to: context.date))
                                .font(.system(size: 40, weight: .heavy, design: .rounded).monospacedDigit())
                        }
                        .foregroundStyle(AppColors.pureWhite)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.xl)
                        .background(AppGradients.heroHome)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }

                    HStack(spacing: AppSpacing.sm) {
                        statCard(value: "\(sessionRecords.count)", label: AppCopy.homeTodayDrinks(appState.currentLanguage))
                        statCard(value: "\(session.hydrationCount)", label: AppCopy.sessionHydration(appState.currentLanguage))
                        statCard(value: "\(Int(round(sessionTotal)))g", label: AppCopy.drinkLogPureAlcohol(appState.currentLanguage))
                    }

                    AICoachBubbleView(
                        context: LocalCoachContext(
                            todayConsumed: sessionTotal,
                            dailyGoal: profile.dailyGoalGrams,
                            isSessionActive: true,
                            hydrationCount: session.hydrationCount,
                            sessionElapsedMinutes: max(0, Int(Date().timeIntervalSince(session.startTime) / 60))
                        ),
                        personality: personality,
                        language: appState.currentLanguage
                    )

                    if praiseVisible || session.preventedLastOrder {
                        Text(AppCopy.sessionStoppedPraise(appState.currentLanguage))
                            .font(AppFonts.body(for: appState.currentLanguage, size: 16))
                            .foregroundStyle(AppColors.charcoal)
                            .padding(AppSpacing.md)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.mintLight)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    actionButton(AppCopy.sessionHydration(appState.currentLanguage), icon: "drop.fill", color: AppColors.mintGreen) {
                        session.hydrationCount += 1
                        saveAndReload()
                    }
                    actionButton(AppCopy.sessionLogDrink(appState.currentLanguage), icon: "plus.circle.fill", color: AppColors.coralRed) {
                        showDrinkLog = true
                    }
                    if profile.lastOrderReminderEnabled {
                        actionButton(AppCopy.sessionLastOrder(appState.currentLanguage), icon: "flag.checkered", color: AppColors.warmCoral) {
                            showLastOrder = true
                        }
                    }
                    actionButton(AppCopy.sessionEnd(appState.currentLanguage), icon: "checkmark.circle", color: AppColors.greyText) {
                        endSession()
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.cream)
            .navigationTitle(AppCopy.homeSessionTitle(appState.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: reload)
        .sheet(isPresented: $showDrinkLog, onDismiss: {
            reload()
            NotificationCenter.default.post(name: .drinkLogSheetDismissed, object: nil)
        }) {
            DrinkLogSheet(sessionID: session.id)
                .environmentObject(appState)
                .presentationDetents([.large])
        }
        .confirmationDialog(AppCopy.sessionLastOrderQuestion(appState.currentLanguage), isPresented: $showLastOrder) {
            Button(AppCopy.sessionStop(appState.currentLanguage)) {
                session.preventedLastOrder = true
                praiseVisible = true
                saveAndReload()
            }
            Button(AppCopy.sessionContinue(appState.currentLanguage)) {
                showDrinkLog = true
            }
            Button(AppCopy.settingsCancel(appState.currentLanguage), role: .cancel) {}
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFonts.statCardValue())
            Text(label)
                .font(AppFonts.sublabel(for: appState.currentLanguage, size: 10))
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(AppColors.charcoal)
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.pureWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func actionButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(AppFonts.body(for: appState.currentLanguage, size: 16))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.md)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func reload() {
        records = (try? modelContext.fetch(FetchDescriptor<DrinkRecord>())) ?? []
        profile = (try? modelContext.fetch(FetchDescriptor<UserProfile>()).first) ?? UserProfile()
    }

    private func saveAndReload() {
        try? modelContext.save()
        NotificationCenter.default.post(name: .sessionDidChange, object: nil)
        reload()
    }

    private func endSession() {
        session.endTime = Date()
        NotificationService.cancelHydrationReminders(sessionID: session.id)
        saveAndReload()
        dismiss()
    }
}
