import Foundation

enum CoachPersonality: String, CaseIterable, Codable, Identifiable, Sendable {
    case strict
    case gentle
    case friendly
    case sarcastic

    var id: String { rawValue }

    var icon: YoiYoiIcon {
        switch self {
        case .strict: .coachDirect
        case .gentle: .coachGentle
        case .friendly: .coachFriendly
        case .sarcastic: .coachWry
        }
    }

    func displayName(_ language: SupportedLanguage) -> String {
        switch (self, language) {
        case (.strict, .ja): "しっかり"
        case (.gentle, .ja): "やさしい"
        case (.friendly, .ja): "フレンドリー"
        case (.sarcastic, .ja): "ひとこと辛口"
        case (.strict, .en): "Direct"
        case (.gentle, .en): "Gentle"
        case (.friendly, .en): "Friendly"
        case (.sarcastic, .en): "Wry"
        }
    }

    func sampleMessage(_ language: SupportedLanguage) -> String {
        switch (self, language) {
        case (.strict, .ja): "ここで一区切り。水も忘れずに。"
        case (.gentle, .ja): "ゆっくりで大丈夫。お水を一杯どうぞ。"
        case (.friendly, .ja): "いいペースで記録中。次はお水タイムにしよう。"
        case (.sarcastic, .ja): "グラスより先に、お水の出番じゃない？"
        case (.strict, .en): "Pause here. Have some water too."
        case (.gentle, .en): "No rush. A glass of water would be kind to you."
        case (.friendly, .en): "Nice logging. Let's make the next round water."
        case (.sarcastic, .en): "How about giving water a turn before the glass?"
        }
    }

    func safetyInstruction(_ language: SupportedLanguage) -> String {
        switch language {
        case .ja:
            "飲酒を勧めず、安全や断定を述べず、水分補給やペースダウンを短く励ましてください。口調は\(displayName(language))。"
        case .en:
            "Never encourage drinking or claim safety. Briefly support slowing down or hydrating in a \(displayName(language).lowercased()) tone."
        }
    }
}
