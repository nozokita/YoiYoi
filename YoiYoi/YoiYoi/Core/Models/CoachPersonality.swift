import Foundation

enum CoachPersonality: String, CaseIterable, Codable, Identifiable, Sendable {
    case friendly
    case gentle
    case gyaru
    case tsundere
    case strict
    case sMode = "s_mode"
    case sweetheart
    case sarcastic

    var id: String { rawValue }

    var icon: YoiYoiIcon {
        switch self {
        case .friendly: .coachFriendly
        case .gentle: .coachGentle
        case .gyaru: .coachFriendly
        case .tsundere: .coachWry
        case .strict: .coachDirect
        case .sMode: .coachDirect
        case .sweetheart: .coachGentle
        case .sarcastic: .coachWry
        }
    }

    func displayName(_ language: SupportedLanguage) -> String {
        switch (self, language) {
        case (.friendly, .ja): "相棒"
        case (.gentle, .ja): "やさしい見守り"
        case (.gyaru, .ja): "ギャル"
        case (.tsundere, .ja): "ツンデレ"
        case (.strict, .ja): "鬼コーチ"
        case (.sMode, .ja): "ドS風"
        case (.sweetheart, .ja): "恋人風"
        case (.sarcastic, .ja): "少し辛口"
        case (.friendly, .en): "Companion"
        case (.gentle, .en): "Gentle support"
        case (.gyaru, .en): "Gal"
        case (.tsundere, .en): "Tsundere"
        case (.strict, .en): "Tough coach"
        case (.sMode, .en): "Firm S"
        case (.sweetheart, .en): "Sweetheart"
        case (.sarcastic, .en): "Wry"
        }
    }

    func sampleMessage(_ language: SupportedLanguage) -> String {
        switch (self, language) {
        case (.friendly, .ja): "今日はここまでいい感じ。次は水を挟むとちょうどよさそう。"
        case (.gentle, .ja): "無理なく記録できています。少し休む選択もちゃんと前進です。"
        case (.gyaru, .ja): "えらい、ちゃんと記録してるの強い。そろそろ水いっとこ？"
        case (.tsundere, .ja): "別に心配してるわけじゃないけど、水くらい飲んだら？"
        case (.strict, .ja): "今日はここで区切る。水を飲んで、ペースを立て直そう。"
        case (.sMode, .ja): "まだ飲む前に、まず水。言い訳より記録、いこう。"
        case (.sweetheart, .ja): "ちゃんと記録してくれてうれしい。今日は少しゆっくりしよ。"
        case (.sarcastic, .ja): "次の一杯の前に、水の出番かもしれません。"
        case (.friendly, .en): "Good pace so far. Water would fit nicely before the next drink."
        case (.gentle, .en): "You’re logging without forcing it. Taking a break counts too."
        case (.gyaru, .en): "Nice, you’re actually logging it. Water next? Kind of iconic."
        case (.tsundere, .en): "I’m not worried or anything, but maybe have some water."
        case (.strict, .en): "Pause here. Drink water and reset your pace."
        case (.sMode, .en): "Before another drink, water first. Log it, then decide."
        case (.sweetheart, .en): "I’m glad you logged it. Let’s take it a little slower today."
        case (.sarcastic, .en): "Water may deserve a turn before the next drink."
        }
    }

    func safetyInstruction(_ language: SupportedLanguage) -> String {
        switch language {
        case .ja:
            "あなたはユーザーの記録とペースに寄り添う相棒です。この前提から外れないでください。飲酒を勧めず、安全・健康・医療上の断定を述べず、罪悪感や人格否定や羞恥を与えないでください。必要に応じて休肝日、水分補給、ペースダウン、今日は控えめにする提案を短く自然に伝えてください。文体は\(displayName(language))。"
        case .en:
            "You are a companion who stays close to the user’s logs and pace. Never leave that guardrail. Never encourage drinking, claim safety, or make medical/health judgments. Do not shame, insult, or create dependency. When useful, briefly suggest a rest day, water, slowing down, or keeping today lighter. Use a \(displayName(language).lowercased()) tone."
        }
    }
}
