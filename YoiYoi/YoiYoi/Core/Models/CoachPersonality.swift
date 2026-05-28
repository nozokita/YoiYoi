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
        case (.strict, .ja): "はっきり"
        case (.gentle, .ja): "やさしい"
        case (.friendly, .ja): "カジュアル"
        case (.sarcastic, .ja): "少し辛口"
        case (.strict, .en): "Direct"
        case (.gentle, .en): "Gentle"
        case (.friendly, .en): "Casual"
        case (.sarcastic, .en): "Wry"
        }
    }

    func sampleMessage(_ language: SupportedLanguage) -> String {
        switch (self, language) {
        case (.strict, .ja): "ここで一度、水を挟みましょう。"
        case (.gentle, .ja): "無理のないペースで。水分も少し取りましょう。"
        case (.friendly, .ja): "記録できています。次は水を挟むのもよさそうです。"
        case (.sarcastic, .ja): "次の一杯の前に、水の出番かもしれません。"
        case (.strict, .en): "Pause here and add some water."
        case (.gentle, .en): "Keep it comfortable. A little water would help."
        case (.friendly, .en): "You’re logging well. Water might be a good next step."
        case (.sarcastic, .en): "Water may deserve a turn before the next drink."
        }
    }

    func safetyInstruction(_ language: SupportedLanguage) -> String {
        switch language {
        case .ja:
            "飲酒を勧めず、安全や断定を述べず、水分補給やペースダウンを短く自然に伝えてください。文体は\(displayName(language))。"
        case .en:
            "Never encourage drinking or claim safety. Briefly suggest slowing down or hydrating in a \(displayName(language).lowercased()) tone."
        }
    }
}
