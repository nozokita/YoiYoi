import Foundation
import Observation

/// 起動直後のルーティング用。`UserProfile.onboardingCompleted` とは二重管理になるため、
/// Phase 4 オンボーディング完了時に **両方** を同じ値に更新する（または Profile を真実源に移行する）。
@Observable
final class AppState {
    private enum Keys {
        static let onboarding = "app.onboardingCompleted"
        static let language = "app.currentLanguage"
    }

    private(set) var onboardingCompleted: Bool
    var currentLanguage: SupportedLanguage {
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
        onboardingCompleted = true
        UserDefaults.standard.set(true, forKey: Keys.onboarding)
    }

    /// デバッグ・テスト用
    func resetOnboardingForDebug() {
        onboardingCompleted = false
        UserDefaults.standard.set(false, forKey: Keys.onboarding)
    }
}
