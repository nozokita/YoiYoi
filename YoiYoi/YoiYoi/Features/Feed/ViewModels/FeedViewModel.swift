import FirebaseFirestore
import Foundation
import Observation
import SwiftData

private enum FeedReactionHighlightStore {
    private static func key(postId: String) -> String { "yoi.feed.reaction.\(postId)" }

    static func save(_ kind: FeedReactionKind, postId: String) {
        UserDefaults.standard.set(kind.rawValue, forKey: key(postId: postId))
    }

    static func load(postId: String) -> FeedReactionKind? {
        UserDefaults.standard.string(forKey: key(postId: postId)).flatMap(FeedReactionKind.init(rawValue:))
    }
}

enum FeedLanguageFilter: String, CaseIterable, Identifiable {
    case all
    case ja
    case en

    var id: String { rawValue }

    func pillLabel(appLanguage: SupportedLanguage) -> String {
        switch self {
        case .all: return AppCopy.feedFilterAll(appLanguage)
        case .ja: return AppCopy.feedFilterJapanese(appLanguage)
        case .en: return AppCopy.feedFilterEnglish(appLanguage)
        }
    }
}

@Observable
@MainActor
final class FeedViewModel {
    var posts: [FeedPost] = []
    var nicknameByUID: [String: FeedUserNickname] = [:]
    var languageFilter: FeedLanguageFilter = .all
    /// リアクション送信失敗（文言は `AppCopy.feedReactionFailed`）。
    var reactionFailed: Bool = false
    private var listener: ListenerRegistration?
    private var fetchingUIDs: Set<String> = []

    func visiblePosts(blockedUIDs: Set<String>) -> [FeedPost] {
        posts
            .filter { !blockedUIDs.contains($0.uid) }
            .filter { post in
                switch languageFilter {
                case .all: return true
                case .ja: return post.language.hasPrefix("ja")
                case .en: return post.language.hasPrefix("en")
                }
            }
    }

    func startListening() {
        listener?.remove()
        listener = FirestoreService.shared.subscribeFeedPosts { [weak self] newPosts in
            Task { @MainActor in
                guard let self else { return }
                self.posts = newPosts
                self.prefetchNicknames(for: newPosts)
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    private func prefetchNicknames(for posts: [FeedPost]) {
        let uids = Set(posts.map(\.uid))
        for uid in uids where nicknameByUID[uid] == nil && !fetchingUIDs.contains(uid) {
            fetchingUIDs.insert(uid)
            Task {
                let nick = try? await FirestoreService.shared.fetchUserNicknameFields(uid: uid)
                await MainActor.run {
                    fetchingUIDs.remove(uid)
                    if let nick {
                        nicknameByUID[uid] = nick
                    }
                }
            }
        }
    }

    func react(to post: FeedPost, kind: FeedReactionKind) async {
        reactionFailed = false
        guard let uid = AuthService.currentUID else { return }
        guard !post.reactedUIDs.contains(uid) else { return }
        do {
            try await FirestoreService.shared.addReaction(
                postId: post.documentID,
                reactionType: kind.rawValue,
                uid: uid
            )
            FeedReactionHighlightStore.save(kind, postId: post.documentID)
        } catch {
            reactionFailed = true
        }
    }

    func reactionHighlight(for post: FeedPost, currentUID: String?) -> FeedReactionKind? {
        guard let currentUID, post.reactedUIDs.contains(currentUID) else { return nil }
        return FeedReactionHighlightStore.load(postId: post.documentID)
    }

    func blockUser(_ uid: String, modelContext: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? modelContext.fetch(descriptor).first else { return }
        var list = profile.blockedUIDs
        if !list.contains(uid) {
            list.append(uid)
            profile.blockedUIDs = list
            try? modelContext.save()
        }
    }

    func submitReport(reporterUID: String, targetUID: String, postID: String, reason: String) async {
        try? await FirestoreService.shared.submitReport(
            reporterUID: reporterUID,
            targetUID: targetUID,
            targetPostID: postID,
            reason: reason
        )
    }
}
