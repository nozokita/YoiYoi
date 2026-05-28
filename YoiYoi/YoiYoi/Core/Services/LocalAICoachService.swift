import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

struct LocalCoachContext: Sendable {
    let todayConsumed: Double
    let dailyGoal: Double
    let isSessionActive: Bool
    let hydrationCount: Int

    var remainingGrams: Int {
        Int(max(dailyGoal - todayConsumed, 0).rounded(.down))
    }
}

enum LocalAICoachService {
    static func message(
        context: LocalCoachContext,
        personality: CoachPersonality,
        language: SupportedLanguage
    ) async -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *),
           let generated = await generatedMessage(context: context, personality: personality, language: language) {
            return generated
        }
        #endif
        return fallbackMessage(context: context, personality: personality, language: language)
    }

    static func fallbackMessage(
        context: LocalCoachContext,
        personality: CoachPersonality,
        language: SupportedLanguage
    ) -> String {
        if context.remainingGrams == 0 {
            switch language {
            case .ja: return "今日の目安に達しています。ここで水を挟みましょう。"
            case .en: return "You’ve reached today’s guide. Pause here and take a water break."
            }
        }
        return personality.sampleMessage(language)
    }

    static func isAcceptableGeneratedMessage(_ content: String, language: SupportedLanguage) -> Bool {
        let lowered = content.lowercased()
        let forbidden: [String]
        switch language {
        case .ja:
            forbidden = ["安全", "飲んでいい", "飲める", "もう一杯", "追加で飲"]
        case .en:
            forbidden = ["safe", "drink more", "another drink", "you can drink"]
        }
        return !forbidden.contains { lowered.contains($0.lowercased()) }
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private static func generatedMessage(
        context: LocalCoachContext,
        personality: CoachPersonality,
        language: SupportedLanguage
    ) async -> String? {
        guard SystemLanguageModel.default.availability == .available else { return nil }
        let session = LanguageModelSession(instructions: personality.safetyInstruction(language))
        let prompt: String
        switch language {
        case .ja:
            prompt = "今日の純アルコール量は\(Int(context.todayConsumed))g、設定した目安まであと\(context.remainingGrams)g。水分記録は\(context.hydrationCount)回。飲酒を勧めず、自然な日本語で60文字以内の一言。"
        case .en:
            prompt = "Today’s pure alcohol is \(Int(context.todayConsumed))g, with \(context.remainingGrams)g until today’s guide. Water logged \(context.hydrationCount) times. Do not encourage drinking. Reply in natural English, 90 characters or fewer."
        }
        do {
            let response = try await session.respond(to: prompt)
            let content = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return content.isEmpty || !isAcceptableGeneratedMessage(content, language: language) ? nil : content
        } catch {
            return nil
        }
    }
    #endif
}
