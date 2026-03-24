import FirebaseCore
import FirebaseFirestore
import Foundation

/// Firestore 読み書き。Firebase 未初期化時はメソッドが静かに失敗または空を返す。
final class FirestoreService: @unchecked Sendable {
    static let shared = FirestoreService()

    private var db: Firestore? {
        guard FirebaseApp.app() != nil else { return nil }
        return Firestore.firestore()
    }

    private init() {}

    func publishFeedPost(_ post: FeedPost) async throws {
        guard let db else { throw FirestoreServiceError.notConfigured }
        let ref = db.collection("feed").document(post.documentID)
        try await ref.setData(post.firestoreData())
    }

    /// SPEC.md のクライアントスニペットに準拠。
    func addReaction(postId: String, reactionType: String, uid: String) async throws {
        guard let db else { throw FirestoreServiceError.notConfigured }
        let ref = db.collection("feed").document(postId)
        try await ref.updateData([
            "reactions.\(reactionType)": FieldValue.increment(Int64(1)),
            "reacted_uids": FieldValue.arrayUnion([uid]),
        ])
    }

    func subscribeFeedPosts(
        limit: Int = 50,
        onUpdate: @escaping @Sendable ([FeedPost]) -> Void
    ) -> ListenerRegistration? {
        guard let db else { return nil }
        let query = db.collection("feed")
            .order(by: "created_at", descending: true)
            .limit(to: limit)

        return query.addSnapshotListener { snapshot, _ in
            let posts: [FeedPost] = snapshot?.documents.compactMap { FeedPost(document: $0) } ?? []
            onUpdate(posts)
        }
    }

    func fetchUserNicknameFields(uid: String) async throws -> FeedUserNickname? {
        guard let db else { throw FirestoreServiceError.notConfigured }
        let snap = try await db.collection("users").document(uid).getDocument()
        guard snap.exists, let data = snap.data() else { return nil }
        guard let flag = data["nickname_flag"] as? String,
              let emoji = data["nickname_emoji"] as? String,
              let adj = data["nickname_adjective"] as? String,
              let noun = data["nickname_noun"] as? String
        else {
            return nil
        }
        let language = data["language"] as? String ?? "ja"
        return FeedUserNickname(
            nicknameFlag: flag,
            nicknameEmoji: emoji,
            nicknameAdjective: adj,
            nicknameNoun: noun,
            language: language
        )
    }

    /// `users/{uid}` をローカル `UserProfile` から同期（匿名ログイン直後・オンボ後）。
    func syncUserDocument(uid: String, profile: UserProfile) async throws {
        guard let db else { throw FirestoreServiceError.notConfigured }
        let ref = db.collection("users").document(uid)
        let data: [String: Any] = [
            "nickname_flag": profile.nicknameFlag,
            "nickname_emoji": profile.nicknameEmoji,
            "nickname_adjective": profile.nicknameAdjective,
            "nickname_noun": profile.nicknameNoun,
            "language": profile.language,
            "created_at": Timestamp(date: profile.createdAt),
        ]
        try await ref.setData(data, merge: true)
    }

    func submitReport(reporterUID: String, targetUID: String, targetPostID: String, reason: String) async throws {
        guard let db else { throw FirestoreServiceError.notConfigured }
        let data: [String: Any] = [
            "reporter_uid": reporterUID,
            "target_uid": targetUID,
            "target_post_id": targetPostID,
            "reason": reason,
            "created_at": FieldValue.serverTimestamp(),
        ]
        _ = try await db.collection("reports").addDocument(data: data)
    }
}

struct FeedUserNickname: Equatable, Sendable {
    var nicknameFlag: String
    var nicknameEmoji: String
    var nicknameAdjective: String
    var nicknameNoun: String
    var language: String

    var compactDisplayName: String {
        "\(nicknameAdjective)\(nicknameNoun)"
    }
}

enum FirestoreServiceError: Error {
    case notConfigured
}
