import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

struct LocalCoachContext: Sendable {
    let todayConsumed: Double
    let dailyGoal: Double
    let isSessionActive: Bool
    let hydrationCount: Int
    var weeklyConsumed: Double = 0
    var weeklyGoal: Double = 0
    var yesterdayConsumed: Double = 0
    var steadyDrinkRawType: String?
    var steadyDrinkAverageGrams: Int = 0
    var riskyDrinkRawType: String?
    var riskyDrinkAverageGrams: Int = 0

    var remainingGrams: Int {
        Int(max(dailyGoal - todayConsumed, 0).rounded(.down))
    }

    var fingerprint: String {
        [
            Int(todayConsumed.rounded()).description,
            Int(dailyGoal.rounded()).description,
            isSessionActive.description,
            hydrationCount.description,
            Int(weeklyConsumed.rounded()).description,
            Int(weeklyGoal.rounded()).description,
            Int(yesterdayConsumed.rounded()).description,
            steadyDrinkRawType ?? "",
            steadyDrinkAverageGrams.description,
            riskyDrinkRawType ?? "",
            riskyDrinkAverageGrams.description,
        ].joined(separator: "|")
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
        if context.yesterdayConsumed > context.dailyGoal, context.todayConsumed == 0 {
            return styled(
                base: .restDay(yesterday: Int(context.yesterdayConsumed.rounded())),
                personality: personality,
                language: language
            )
        }
        if context.weeklyGoal > 0, context.weeklyConsumed >= context.weeklyGoal * 0.8, context.todayConsumed < context.dailyGoal * 0.5 {
            return styled(
                base: .lighterToday(weekly: Int(context.weeklyConsumed.rounded())),
                personality: personality,
                language: language
            )
        }
        if let risky = context.riskyDrinkRawType {
            return styled(
                base: .drinkTrend(
                    steadyRawType: context.steadyDrinkRawType,
                    steadyAverage: context.steadyDrinkAverageGrams,
                    riskyRawType: risky,
                    riskyAverage: context.riskyDrinkAverageGrams
                ),
                personality: personality,
                language: language
            )
        }
        if context.remainingGrams == 0 {
            switch language {
            case .ja: return styled(base: .overGuide, personality: personality, language: language)
            case .en: return styled(base: .overGuide, personality: personality, language: language)
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
            prompt = """
            今日の純アルコール量は\(Int(context.todayConsumed))g、昨日は\(Int(context.yesterdayConsumed))g、今週は\(Int(context.weeklyConsumed))g、設定した目安まであと\(context.remainingGrams)g。水分記録は\(context.hydrationCount)回。傾向: \(trendPrompt(context, language: language))。飲酒を勧めず、必要なら休肝日・今日は控えめ・水分補給を提案。自然な日本語で70文字以内の一言。
            """
        case .en:
            prompt = """
            Today’s pure alcohol is \(Int(context.todayConsumed))g, yesterday was \(Int(context.yesterdayConsumed))g, this week is \(Int(context.weeklyConsumed))g, with \(context.remainingGrams)g until today’s guide. Water logged \(context.hydrationCount) times. Trend: \(trendPrompt(context, language: language)). Do not encourage drinking. Suggest a rest day, lighter day, or water if useful. Reply in natural English, 100 characters or fewer.
            """
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

private enum CoachBaseMessage {
    case restDay(yesterday: Int)
    case lighterToday(weekly: Int)
    case drinkTrend(steadyRawType: String?, steadyAverage: Int, riskyRawType: String, riskyAverage: Int)
    case overGuide
}

private extension LocalAICoachService {
    static func styled(base: CoachBaseMessage, personality: CoachPersonality, language: SupportedLanguage) -> String {
        switch (base, personality, language) {
        case (.restDay(let yesterday), .friendly, .ja):
            "昨日は\(yesterday)g。今日は休肝日にするのも、かなりいい相棒ムーブ。"
        case (.restDay(let yesterday), .gentle, .ja):
            "昨日は\(yesterday)gでした。今日は休む選択も、体にやさしい記録です。"
        case (.restDay(let yesterday), .gyaru, .ja):
            "昨日\(yesterday)gいってるね。今日は休肝日にできたらかなり強い。"
        case (.restDay, .tsundere, .ja):
            "別に止めたいわけじゃないけど、今日は休肝日でもいいんじゃない？"
        case (.restDay, .strict, .ja):
            "今日は休肝日候補。昨日の分、ここでペースを整えよう。"
        case (.restDay, .sMode, .ja):
            "今日はまず休む判断。飲む前に、昨日の記録を見てから決めよう。"
        case (.restDay, .sweetheart, .ja):
            "昨日少し多めだったね。今日は一緒にゆっくり休む日にしよ。"
        case (.restDay, .sarcastic, .ja):
            "昨日の記録を見る限り、今日はグラスより休肝日の出番かも。"
        case (.lighterToday(let weekly), .friendly, .ja):
            "今週は\(weekly)g。今日は少し控えめにすると、いいペースに戻せそう。"
        case (.lighterToday(let weekly), .gentle, .ja):
            "今週は\(weekly)gです。今日は少なめにするだけでも十分整います。"
        case (.lighterToday, .gyaru, .ja):
            "今週ちょい多めかも。今日は控えめにできたら、かなりえらい。"
        case (.lighterToday, .tsundere, .ja):
            "今週ちょっと多いし、今日は控えめでもいいんじゃない。別に。"
        case (.lighterToday, .strict, .ja):
            "今週は多め。今日は量を先に決めて、そこで区切ろう。"
        case (.lighterToday, .sMode, .ja):
            "今日は控えめ。先に量を決める、そこから動かない。"
        case (.lighterToday, .sweetheart, .ja):
            "今週少し多めかも。今日は無理せず、少し控えめにしよ。"
        case (.lighterToday, .sarcastic, .ja):
            "今週の数字、少し主張が強いです。今日は控えめがよさそう。"
        case (.drinkTrend(let steady, let steadyAverage, let risky, let riskyAverage), _, .ja):
            drinkTrendMessage(steadyRawType: steady, steadyAverage: steadyAverage, riskyRawType: risky, riskyAverage: riskyAverage, language: language)
        case (.overGuide, .friendly, .ja):
            "今日の目安に達しています。ここで水を挟んで、ペースを整えよう。"
        case (.overGuide, .gentle, .ja):
            "今日の目安に達しています。少し休む選択もちゃんと前進です。"
        case (.overGuide, .gyaru, .ja):
            "今日は目安まで来てる。ここで水いけたら、かなりいい感じ。"
        case (.overGuide, .tsundere, .ja):
            "もう目安まで来てるし、水くらい挟んだら？心配とかじゃないけど。"
        case (.overGuide, .strict, .ja):
            "今日の目安に達しています。ここで区切って、水を飲もう。"
        case (.overGuide, .sMode, .ja):
            "今日はここで区切る。次に必要なのは追加じゃなくて水。"
        case (.overGuide, .sweetheart, .ja):
            "今日はここまでで十分。水を飲んで、少しゆっくりしよ。"
        case (.overGuide, .sarcastic, .ja):
            "今日の目安には到着済みです。次の目的地は水でどうでしょう。"
        case (.restDay(let yesterday), _, .en):
            "Yesterday was \(yesterday)g. A rest day today would be a strong choice."
        case (.lighterToday(let weekly), _, .en):
            "This week is \(weekly)g. Keeping today lighter could help your pace."
        case (.drinkTrend(let steady, let steadyAverage, let risky, let riskyAverage), _, .en):
            drinkTrendMessage(steadyRawType: steady, steadyAverage: steadyAverage, riskyRawType: risky, riskyAverage: riskyAverage, language: language)
        case (.overGuide, _, .en):
            "You’ve reached today’s guide. Pause here and take a water break."
        }
    }

    static func drinkTrendMessage(
        steadyRawType: String?,
        steadyAverage: Int,
        riskyRawType: String,
        riskyAverage: Int,
        language: SupportedLanguage
    ) -> String {
        let risky = DrinkType.shortLabel(forRawType: riskyRawType, language: language)
        switch language {
        case .ja:
            if let steadyRawType, steadyAverage > 0 {
                let steady = DrinkType.shortLabel(forRawType: steadyRawType, language: language)
                return "\(steady)は平均\(steadyAverage)g、\(risky)は\(riskyAverage)gになりがち。\(risky)は量を先に決めよう。"
            }
            return "\(risky)は平均\(riskyAverage)gになりがち。今日は量を先に決めておこう。"
        case .en:
            if let steadyRawType, steadyAverage > 0 {
                let steady = DrinkType.shortLabel(forRawType: steadyRawType, language: language)
                return "\(steady) averages \(steadyAverage)g; \(risky) tends toward \(riskyAverage)g. Set a limit first."
            }
            return "\(risky) tends toward \(riskyAverage)g. Set your amount before you start."
        }
    }

    static func trendPrompt(_ context: LocalCoachContext, language: SupportedLanguage) -> String {
        guard let risky = context.riskyDrinkRawType else {
            switch language {
            case .ja: return "まだ十分な傾向データなし"
            case .en: return "not enough trend data yet"
            }
        }
        return drinkTrendMessage(
            steadyRawType: context.steadyDrinkRawType,
            steadyAverage: context.steadyDrinkAverageGrams,
            riskyRawType: risky,
            riskyAverage: context.riskyDrinkAverageGrams,
            language: language
        )
    }
}
