import FirebaseCore
import Foundation

/// 飲酒記録保存後のフィード投稿（失敗は握りつぶし）。
enum FeedFirestoreSync {
    @MainActor
    static func publishIfPossible(_ post: FeedPost) {
        guard FeatureFlags.isFeedEnabled, FirebaseBootstrap.isFirebaseUsable else { return }
        guard let uid = AuthService.currentUID else { return }
        var post = post
        post.uid = uid
        Task {
            do {
                try await FirestoreService.shared.publishFeedPost(post)
            } catch {
                // MVP: ローカル記録は成功済み。ネットワーク・ルールエラーは無視。
            }
        }
    }
}
