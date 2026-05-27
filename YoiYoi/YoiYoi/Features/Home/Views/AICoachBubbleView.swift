import SwiftUI

struct AICoachBubbleView: View {
    let context: LocalCoachContext
    let personality: CoachPersonality
    let language: SupportedLanguage

    @State private var message = ""
    @State private var refreshID = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
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
                Button {
                    refreshID = UUID()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel(AppCopy.homeCoachReload(language))
                .foregroundStyle(AppColors.coralRed)
            }
            Text(message.isEmpty ? personality.sampleMessage(language) : message)
                .font(AppFonts.body(for: language, size: 15))
                .foregroundStyle(AppColors.charcoal)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.yellowLight)
        .task(id: refreshID) {
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
        }
    }
}
