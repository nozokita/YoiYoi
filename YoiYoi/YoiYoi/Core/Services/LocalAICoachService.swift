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
    var todaysRecordCount: Int = 0
    var latestDrinkGrams: Int = 0
    var minutesSinceLastDrink: Int?
    var recentLogGapMinutes: Int?
    var sessionElapsedMinutes: Int?
    var loggingStreakDays: Int = 0
    var plannedDrinkRawType: String?
    var plannedDrinkCount: Int = 1
    var plannedDrinkVolumeML: Int = 0
    var riskyWeekday: Int?
    var riskyTimeSlot: String?

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
            todaysRecordCount.description,
            latestDrinkGrams.description,
            minutesSinceLastDrink?.description ?? "",
            recentLogGapMinutes?.description ?? "",
            sessionElapsedMinutes?.description ?? "",
            loggingStreakDays.description,
            plannedDrinkRawType ?? "",
            plannedDrinkCount.description,
            plannedDrinkVolumeML.description,
            riskyWeekday?.description ?? "",
            riskyTimeSlot ?? "",
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
        if let elapsed = context.sessionElapsedMinutes, elapsed >= 90 {
            return styled(base: .sessionLastOrder(elapsed: elapsed), personality: personality, language: language)
        }
        if let elapsed = context.sessionElapsedMinutes, elapsed >= 60 {
            return styled(base: .sessionPace(elapsed: elapsed), personality: personality, language: language)
        }
        if let gap = context.recentLogGapMinutes, gap <= 45, context.todaysRecordCount >= 2 {
            return styled(base: .paceGap(minutes: gap), personality: personality, language: language)
        }
        if let minutes = context.minutesSinceLastDrink, minutes <= 10, context.latestDrinkGrams > 0 {
            return styled(base: .afterLog(today: Int(context.todayConsumed.rounded()), remaining: context.remainingGrams), personality: personality, language: language)
        }
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
        if context.todayConsumed == 0, let weekday = context.riskyWeekday {
            return styled(base: .weekdayRisk(weekday: weekday), personality: personality, language: language)
        }
        if context.todayConsumed == 0, let slot = context.riskyTimeSlot {
            return styled(base: .timeRisk(slot: slot), personality: personality, language: language)
        }
        if context.loggingStreakDays >= 3, context.todaysRecordCount > 0 {
            return styled(base: .loggingStreak(days: context.loggingStreakDays), personality: personality, language: language)
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
        if context.todayConsumed == 0 {
            return styled(
                base: .preDrink(
                    rawType: context.plannedDrinkRawType,
                    count: context.plannedDrinkCount,
                    volumeML: context.plannedDrinkVolumeML
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
            今日の純アルコール量は\(Int(context.todayConsumed))g、昨日は\(Int(context.yesterdayConsumed))g、今週は\(Int(context.weeklyConsumed))g、設定した目安まであと\(context.remainingGrams)g。水分記録は\(context.hydrationCount)回。状況: \(contextPrompt(context, language: language))。傾向: \(trendPrompt(context, language: language))。飲酒を勧めず、必要なら休肝日・今日は控えめ・水分補給・先に量を決める提案をする。自然な日本語で70文字以内の一言。
            """
        case .en:
            prompt = """
            Today’s pure alcohol is \(Int(context.todayConsumed))g, yesterday was \(Int(context.yesterdayConsumed))g, this week is \(Int(context.weeklyConsumed))g, with \(context.remainingGrams)g until today’s guide. Water logged \(context.hydrationCount) times. Context: \(contextPrompt(context, language: language)). Trend: \(trendPrompt(context, language: language)). Do not encourage drinking. Suggest a rest day, lighter day, water, or setting an amount first if useful. Reply in natural English, 100 characters or fewer.
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
    case preDrink(rawType: String?, count: Int, volumeML: Int)
    case afterLog(today: Int, remaining: Int)
    case paceGap(minutes: Int)
    case restDay(yesterday: Int)
    case lighterToday(weekly: Int)
    case drinkTrend(steadyRawType: String?, steadyAverage: Int, riskyRawType: String, riskyAverage: Int)
    case timeRisk(slot: String)
    case weekdayRisk(weekday: Int)
    case loggingStreak(days: Int)
    case sessionPace(elapsed: Int)
    case sessionLastOrder(elapsed: Int)
    case overGuide
}

private extension LocalAICoachService {
    static func styled(base: CoachBaseMessage, personality: CoachPersonality, language: SupportedLanguage) -> String {
        switch (base, personality, language) {
        case (.preDrink(let rawType, let count, let volumeML), _, .ja):
            preDrinkMessage(rawType: rawType, count: count, volumeML: volumeML, language: language)
        case (.afterLog(let today, let remaining), _, .ja):
            remaining > 0
                ? "記録できました。今の時点で今日は\(today)g、目安まであと\(remaining)gです。"
                : "記録できました。今日はここで水を挟んで、ペースを整えよう。"
        case (.paceGap(let minutes), _, .ja):
            "短い時間で続けて記録されています。\(minutes)分間隔なので、少し間を空けてもよさそう。"
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
        case (.timeRisk(let slot), _, .ja):
            timeRiskMessage(slot: slot, language: language)
        case (.weekdayRisk(let weekday), _, .ja):
            "\(weekdayName(weekday, language: language))は多くなりやすい傾向です。今日は最初に量を決めておくのがよさそう。"
        case (.loggingStreak(let days), _, .ja):
            "\(days)日続けて記録できています。完璧じゃなくて、続いているのがいいです。"
        case (.sessionPace(let elapsed), _, .ja):
            "開始から\(elapsed)分。ここで水を挟むと、後半のペースを整えやすいです。"
        case (.sessionLastOrder(let elapsed), _, .ja):
            "開始から\(elapsed)分。そろそろ区切りを決める選択もありです。"
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
        case (.preDrink(let rawType, let count, let volumeML), _, .en):
            preDrinkMessage(rawType: rawType, count: count, volumeML: volumeML, language: language)
        case (.afterLog(let today, let remaining), _, .en):
            remaining > 0
                ? "Logged. You’re at \(today)g today, with \(remaining)g until your guide."
                : "Logged. You’ve reached today’s guide; water would help reset the pace."
        case (.paceGap(let minutes), _, .en):
            "Several logs are close together, about \(minutes) minutes apart. A pause could help."
        case (.restDay(let yesterday), _, .en):
            "Yesterday was \(yesterday)g. A rest day today would be a strong choice."
        case (.lighterToday(let weekly), _, .en):
            "This week is \(weekly)g. Keeping today lighter could help your pace."
        case (.drinkTrend(let steady, let steadyAverage, let risky, let riskyAverage), _, .en):
            drinkTrendMessage(steadyRawType: steady, steadyAverage: steadyAverage, riskyRawType: risky, riskyAverage: riskyAverage, language: language)
        case (.timeRisk(let slot), _, .en):
            timeRiskMessage(slot: slot, language: language)
        case (.weekdayRisk(let weekday), _, .en):
            "\(weekdayName(weekday, language: language)) tends to run higher. Setting an amount first could help."
        case (.loggingStreak(let days), _, .en):
            "\(days) days of logging. It doesn’t need to be perfect; seeing the pace matters."
        case (.sessionPace(let elapsed), _, .en):
            "\(elapsed) minutes in. Water here could make the rest of the session easier."
        case (.sessionLastOrder(let elapsed), _, .en):
            "\(elapsed) minutes in. This could be a good time to choose your stopping point."
        case (.overGuide, _, .en):
            "You’ve reached today’s guide. Pause here and take a water break."
        }
    }

    static func preDrinkMessage(rawType: String?, count: Int, volumeML: Int, language: SupportedLanguage) -> String {
        guard let rawType else {
            switch language {
            case .ja: return "今日は先に「ここまで」を決めておく？軽めスタートでもよさそう。"
            case .en: return "Want to set an amount first today? Starting light could work well."
            }
        }
        let drink = DrinkType.shortLabel(forRawType: rawType, language: language)
        switch language {
        case .ja:
            if rawType == DrinkType.wine.rawValue, volumeML > 0 {
                return "\(drink)は\(volumeML)ml単位なら安定しやすそう。今日はそのペースでいく？"
            }
            return "今日は最初に「\(drink)\(count)杯まで」みたいに決めておく？"
        case .en:
            if rawType == DrinkType.wine.rawValue, volumeML > 0 {
                return "\(drink) at \(volumeML)ml pours looks easier to pace. Want to use that today?"
            }
            return "Want to decide up front, like \(count) \(drink.lowercased()) drinks today?"
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

    static func timeRiskMessage(slot: String, language: SupportedLanguage) -> String {
        switch (slot, language) {
        case ("lateNight", .ja):
            return "遅い時間の記録は量が増えやすい傾向です。今日は早めに区切る？"
        case ("lateNight", .en):
            return "Late-night logs tend to run higher. Want to choose an earlier stopping point?"
        default:
            switch language {
            case .ja: return "この時間帯は多くなりやすい傾向です。先に量を決めておこう。"
            case .en: return "This time of day tends to run higher. Setting an amount first could help."
            }
        }
    }

    static func weekdayName(_ weekday: Int, language: SupportedLanguage) -> String {
        switch language {
        case .ja:
            let names = ["日曜", "月曜", "火曜", "水曜", "木曜", "金曜", "土曜"]
            guard (1...7).contains(weekday) else { return "この曜日" }
            return names[weekday - 1]
        case .en:
            let names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            guard (1...7).contains(weekday) else { return "This weekday" }
            return names[weekday - 1]
        }
    }

    static func contextPrompt(_ context: LocalCoachContext, language: SupportedLanguage) -> String {
        var parts: [String] = []
        if let minutes = context.minutesSinceLastDrink {
            parts.append(language == .ja ? "最後の記録から\(minutes)分" : "\(minutes) minutes since last log")
        }
        if let gap = context.recentLogGapMinutes {
            parts.append(language == .ja ? "直近の記録間隔\(gap)分" : "recent log gap \(gap) minutes")
        }
        if let elapsed = context.sessionElapsedMinutes {
            parts.append(language == .ja ? "飲み会開始から\(elapsed)分" : "session elapsed \(elapsed) minutes")
        }
        if context.loggingStreakDays >= 3 {
            parts.append(language == .ja ? "\(context.loggingStreakDays)日連続記録" : "\(context.loggingStreakDays)-day logging streak")
        }
        if let weekday = context.riskyWeekday {
            parts.append(language == .ja ? "\(weekdayName(weekday, language: language))に多くなりやすい" : "\(weekdayName(weekday, language: language)) tends higher")
        }
        if let slot = context.riskyTimeSlot {
            parts.append(timeRiskMessage(slot: slot, language: language))
        }
        if parts.isEmpty {
            return language == .ja ? "開始前の量決めが有効" : "setting an amount first may help"
        }
        return parts.joined(separator: " / ")
    }
}
