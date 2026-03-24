import Foundation

/// Firestore `reactions` のキーと UI 絵文字。
enum FeedReactionKind: String, CaseIterable, Identifiable {
    case clap
    case fire
    case muscle
    case hug
    case clover
    case cheers

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .clap: return "👏"
        case .fire: return "🔥"
        case .muscle: return "💪"
        case .hug: return "🫂"
        case .clover: return "🍀"
        case .cheers: return "🥂"
        }
    }

    func count(for post: FeedPost) -> Int {
        switch self {
        case .clap: return post.reactions.clap
        case .fire: return post.reactions.fire
        case .muscle: return post.reactions.muscle
        case .hug: return post.reactions.hug
        case .clover: return post.reactions.clover
        case .cheers: return post.reactions.cheers
        }
    }
}
