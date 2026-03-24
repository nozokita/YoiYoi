import FirebaseAuth
import FirebaseCore
import Foundation
import SwiftData

/// 匿名 Firebase Auth。`GoogleService-Info.plist` 未配置時は no-op。
@MainActor
enum AuthService {
    static var currentUID: String? {
        guard FirebaseApp.app() != nil else { return nil }
        return Auth.auth().currentUser?.uid
    }

    static func signInAnonymouslyIfNeeded() async throws {
        guard FirebaseApp.app() != nil else { return }
        if Auth.auth().currentUser != nil { return }
        _ = try await Auth.auth().signInAnonymously()
    }

    /// SwiftData の `firebaseUID` を Auth と揃える。
    static func syncLocalProfileFirebaseUID(modelContext: ModelContext) {
        guard let uid = currentUID else { return }
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? modelContext.fetch(descriptor).first else { return }
        if profile.firebaseUID != uid {
            profile.firebaseUID = uid
            try? modelContext.save()
        }
    }
}
