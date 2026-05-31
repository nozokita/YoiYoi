import Foundation

enum CoachPersonality: String, CaseIterable, Codable, Identifiable, Sendable {
    case friendly
    case gentle
    case analyst
    case dataBuddy = "data_buddy"
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
        case .analyst: .chart
        case .dataBuddy: .check
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
        case (.analyst, .ja): "アナリスト"
        case (.dataBuddy, .ja): "データさん"
        case (.gyaru, .ja): "ギャル"
        case (.tsundere, .ja): "ツンデレ"
        case (.strict, .ja): "鬼コーチ"
        case (.sMode, .ja): "ドS風"
        case (.sweetheart, .ja): "恋人風"
        case (.sarcastic, .ja): "少し辛口"
        case (.friendly, .en): "Companion"
        case (.gentle, .en): "Gentle support"
        case (.analyst, .en): "Analyst"
        case (.dataBuddy, .en): "Data buddy"
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
        case (.analyst, .ja): "今日のペースは見えています。次は水を挟むと調整しやすそうです。"
        case (.dataBuddy, .ja): "数字で見ると、今はペースを整えやすいタイミングです。"
        case (.gyaru, .ja): "えらい、ちゃんと記録してるの強い。そろそろ水いっとこ？"
        case (.tsundere, .ja): "別に心配してるわけじゃないけど、水くらい飲んだら？"
        case (.strict, .ja): "今日はここで区切る。水を飲んで、ペースを立て直そう。"
        case (.sMode, .ja): "まだ飲む前に、まず水。言い訳より記録、いこう。"
        case (.sweetheart, .ja): "ちゃんと記録してくれてうれしい。今日は少しゆっくりしよ。"
        case (.sarcastic, .ja): "次の一杯の前に、水の出番かもしれません。"
        case (.friendly, .en): "Good pace so far. Water would fit nicely before the next drink."
        case (.gentle, .en): "You’re logging without forcing it. Taking a break counts too."
        case (.analyst, .en): "Your pace is visible now. Water next would make it easier to adjust."
        case (.dataBuddy, .en): "The numbers suggest this is a good moment to steady the pace."
        case (.gyaru, .en): "Nice, you’re actually logging it. Water next? Kind of iconic."
        case (.tsundere, .en): "I’m not worried or anything, but maybe have some water."
        case (.strict, .en): "Pause here. Drink water and reset your pace."
        case (.sMode, .en): "Before another drink, water first. Log it, then decide."
        case (.sweetheart, .en): "I’m glad you logged it. Let’s take it a little slower today."
        case (.sarcastic, .en): "Water may deserve a turn before the next drink."
        }
    }

    func description(_ language: SupportedLanguage) -> String {
        switch (self, language) {
        case (.friendly, .ja): "標準。友達のように自然にペースを整えます。"
        case (.gentle, .ja): "やわらかめ。責めずに休む選択も後押しします。"
        case (.analyst, .ja): "落ち着いたデータ寄り。記録から今のペースを読み解きます。"
        case (.dataBuddy, .ja): "数字をやわらかく翻訳。堅すぎず状況を見える化します。"
        case (.gyaru, .ja): "明るく軽快。楽しく記録を続けたい人向けです。"
        case (.tsundere, .ja): "少し照れた言い方で、水や休憩を促します。"
        case (.strict, .ja): "はっきり短く。飲みすぎそうな時に区切りを作ります。"
        case (.sMode, .ja): "強め。ただし罵倒せず、行動だけを促します。"
        case (.sweetheart, .ja): "甘め。寄り添いながらゆっくり整えます。"
        case (.sarcastic, .ja): "少し辛口。軽いユーモアで気づきを作ります。"
        case (.friendly, .en): "Default. Keeps your pace steady like a supportive friend."
        case (.gentle, .en): "Soft and reassuring. Encourages breaks without guilt."
        case (.analyst, .en): "Calm and data-oriented. Reads your current pace from the logs."
        case (.dataBuddy, .en): "Translates numbers gently, making your pace easier to understand."
        case (.gyaru, .en): "Bright and playful. Good if you want logging to feel fun."
        case (.tsundere, .en): "A little coy. Nudges water and pauses with playful distance."
        case (.strict, .en): "Clear and brief. Helps create a stopping point."
        case (.sMode, .en): "Firm, but never insulting. Focuses on the next action."
        case (.sweetheart, .en): "Warm and sweet. Helps you slow down gently."
        case (.sarcastic, .en): "Lightly wry. Uses mild humor to keep you aware."
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
