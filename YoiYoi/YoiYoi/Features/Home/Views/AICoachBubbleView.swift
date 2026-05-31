import SwiftUI

struct AICoachBubbleView: View {
    @Environment(\.modelContext) private var modelContext

    let context: LocalCoachContext
    let personality: CoachPersonality
    let language: SupportedLanguage
    var refreshTrigger: String = ""

    @State private var message = ""
    @State private var refreshID = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(AppCopy.homeCoachTitle(language))
                    .font(AppFonts.cardTitle())
                    .foregroundStyle(AppColors.charcoal)
                Spacer()
                HStack(spacing: 4) {
                    SVGIcon(icon: personality.icon, size: 13, color: AppColors.greyText)
                    Text(personality.displayName(language))
                        .font(AppFonts.sublabel(for: language, size: 11))
                        .foregroundStyle(AppColors.greyText)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, 5)
                .background(AppColors.mintLight.opacity(0.72))
                .clipShape(Capsule())
                Button {
                    refreshID = UUID()
                    TelemetryService.track(
                        .aiCommentRefreshed,
                        screen: .home,
                        attributes: ["personality": personality.rawValue],
                        modelContext: modelContext
                    )
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel(AppCopy.homeCoachReload(language))
                .foregroundStyle(AppColors.coralRed)
            }
            Text(message.isEmpty ? personality.sampleMessage(language) : message)
                .font(AppFonts.body(for: language, size: 15))
                .foregroundStyle(AppColors.charcoal)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            Text(AppCopy.homeCoachDisclaimer(language))
                .font(AppFonts.sublabel(for: language, size: 11))
                .foregroundStyle(AppColors.greyText.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.yellowLight)
        .task(id: taskID) {
            message = LocalAICoachService.fallbackMessage(
                context: context,
                personality: personality,
                language: language
            )
            guard !ProcessInfo.processInfo.arguments.contains("-YoiYoiUITesting") else { return }
            message = await LocalAICoachService.message(
                context: context,
                personality: personality,
                language: language
            )
            TelemetryService.track(
                .aiCommentRendered,
                screen: .home,
                attributes: [
                    "personality": personality.rawValue,
                    "today_ratio": TelemetryService.ratioBand(consumed: context.todayConsumed, goal: context.dailyGoal),
                    "has_recent_log": context.minutesSinceLastDrink.map { $0 <= 10 } == true ? "true" : "false",
                ],
                modelContext: modelContext
            )
        }
    }

    private var taskID: String {
        "\(refreshID.uuidString)|\(refreshTrigger)|\(context.fingerprint)|\(personality.rawValue)|\(language.rawValue)"
    }
}
