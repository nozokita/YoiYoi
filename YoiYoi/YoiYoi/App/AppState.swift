import Foundation
import SwiftUI

/// 起動直後のルーティング用。`UserProfile.onboardingCompleted` とは二重管理になるため、
/// Phase 4 オンボーディング完了時に **両方** を同じ値に更新する（または Profile を真実源に移行する）。
///
/// **Note:** `@Observable` + `@Environment(AppState.self)` は `App` / `Scene` 直下で更新が伝わらず
/// 真っ白なウィンドウになる事例があるため、`ObservableObject` + `@EnvironmentObject` を採用する。
@MainActor
final class AppState: ObservableObject {
    private enum Keys {
        static let onboarding = "app.onboardingCompleted"
        static let language = "app.currentLanguage"
    }

    @Published private(set) var onboardingCompleted: Bool
    @Published var currentLanguage: SupportedLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Keys.language)
        }
    }

    init() {
        onboardingCompleted = UserDefaults.standard.bool(forKey: Keys.onboarding)
        let raw = UserDefaults.standard.string(forKey: Keys.language) ?? SupportedLanguage.ja.rawValue
        currentLanguage = SupportedLanguage(rawValue: raw) ?? .ja
    }

    func completeOnboarding() {
        objectWillChange.send()
        onboardingCompleted = true
        UserDefaults.standard.set(true, forKey: Keys.onboarding)
    }

    /// デバッグ・テスト用
    func resetOnboardingForDebug() {
        onboardingCompleted = false
        UserDefaults.standard.set(false, forKey: Keys.onboarding)
    }
}
