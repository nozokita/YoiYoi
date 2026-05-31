import Testing
@testable import YoiYoi

struct LocalAICoachServiceTests {
    @Test func fallbackAtGoalSuggestsPauseInsteadOfAnotherDrink() {
        let message = LocalAICoachService.fallbackMessage(
            context: LocalCoachContext(todayConsumed: 40, dailyGoal: 40, isSessionActive: true, hydrationCount: 0),
            personality: .friendly,
            language: .en
        )
        #expect(message.contains("Pause"))
        #expect(!message.localizedCaseInsensitiveContains("drink more"))
    }

    @Test func personalitySampleIsLocalized() {
        #expect(CoachPersonality.gentle.sampleMessage(.ja) != CoachPersonality.gentle.sampleMessage(.en))
    }

    @Test func generatedMessageGuardRejectsUnsafePhrasing() {
        #expect(!LocalAICoachService.isAcceptableGeneratedMessage("You can drink more safely.", language: .en))
        #expect(!LocalAICoachService.isAcceptableGeneratedMessage("もう一杯飲めるよ", language: .ja))
        #expect(LocalAICoachService.isAcceptableGeneratedMessage("Water break time.", language: .en))
    }
}
