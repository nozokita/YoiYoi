import Foundation
import Observation
import SwiftData
import SwiftUI

/// オンボーディング完了処理が `guard` で打ち切られたときにユーザーへ理由を示す。
enum OnboardingCompletionError: LocalizedError {
    case eulaNotAccepted
    case languageNotSelected
    case other(String)

    func message(language: SupportedLanguage) -> String {
        switch self {
        case .eulaNotAccepted:
            return AppCopy.onboardingErrorEULANotAccepted(language)
        case .languageNotSelected:
            return AppCopy.onboardingErrorLanguageNotSelected(language)
        case .other(let msg):
            return msg
        }
    }

    var errorDescription: String? {
        switch self {
        case .eulaNotAccepted:
            return AppCopy.onboardingErrorEULANotAccepted(.ja)
        case .languageNotSelected:
            return AppCopy.onboardingErrorLanguageNotSelected(.ja)
        case .other(let msg):
            return msg
        }
    }
}

enum OnboardingGender: String, CaseIterable, Sendable {
    case male
    case female
    case custom
}

/// オンボーディングの状態と `UserProfile` への永続化（SPEC / IMPLEMENTATION_PLAN Phase 4）。
@Observable
@MainActor
final class OnboardingViewModel {
    var eulaAccepted = false
    var eulaAcceptedAt: Date?

    var selectedLanguage: SupportedLanguage?

    var selectedGender: OnboardingGender = .male
    var dailyGoal: Double = 25
    var weeklyGoal: Double = 175

    var flagOptions: [String] = []
    var emojiOptions: [String] = []
    var adjectiveOptions: [String] = []
    var nounOptions: [String] = []

    var selectedFlag: String?
    var selectedEmoji: String?
    var selectedAdjective: String?
    var selectedNoun: String?

    private var didLoadNicknameLists = false
    private var lastNicknameLanguage: SupportedLanguage?

    init() {
        applyGoalsForGender(.male)
    }

    func applyGoalsForGender(_ gender: OnboardingGender) {
        selectedGender = gender
        switch gender {
        case .male:
            dailyGoal = 25
            weeklyGoal = 175
        case .female:
            dailyGoal = 15
            weeklyGoal = 105
        case .custom:
            dailyGoal = 40
            weeklyGoal = 280
        }
    }

    func adjustDailyGoal(by delta: Double) {
        let next = (dailyGoal + delta).clamped(to: 5...120)
        dailyGoal = next
    }

    func adjustWeeklyGoal(by delta: Double) {
        let next = (weeklyGoal + delta).clamped(to: 35...980)
        weeklyGoal = next
    }

    func acceptEULA() {
        eulaAccepted = true
        eulaAcceptedAt = Date()
    }

    func loadNicknameDataIfNeeded(bundle: Bundle = .main) throws {
        let lang = selectedLanguage ?? .ja
        if didLoadNicknameLists, lastNicknameLanguage == lang {
            pickDefaultsIfNeeded()
            return
        }
        flagOptions = try NicknamePresets.flags(bundle: bundle)
        emojiOptions = try NicknamePresets.emojis(bundle: bundle)
        adjectiveOptions = try NicknamePresets.adjectives(for: lang, bundle: bundle)
        nounOptions = try NicknamePresets.nouns(for: lang, bundle: bundle)
        didLoadNicknameLists = true
        lastNicknameLanguage = lang
        pickDefaultsIfNeeded()
    }

    func pickDefaultsIfNeeded() {
        selectedFlag = selectedFlag ?? flagOptions.first
        selectedEmoji = selectedEmoji ?? emojiOptions.first
        selectedAdjective = selectedAdjective ?? adjectiveOptions.first
        selectedNoun = selectedNoun ?? nounOptions.first
    }

    func shuffleNickname() {
        if let f = flagOptions.randomElement() { selectedFlag = f }
        if let e = emojiOptions.randomElement() { selectedEmoji = e }
        if let a = adjectiveOptions.randomElement() { selectedAdjective = a }
        if let n = nounOptions.randomElement() { selectedNoun = n }
    }

    /// `UserProfile` を保存し、`AppState` と言語・オンボーディング完了を同期する。
    func completeOnboarding(modelContext: ModelContext, appState: AppState) throws {
        guard eulaAccepted else { throw OnboardingCompletionError.eulaNotAccepted }
        guard let lang = selectedLanguage else { throw OnboardingCompletionError.languageNotSelected }

        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(descriptor)
        let profile: UserProfile
        if let existing = profiles.first {
            profile = existing
        } else {
            profile = UserProfile()
            modelContext.insert(profile)
        }

        profile.eulaAccepted = true
        profile.eulaAcceptedAt = eulaAcceptedAt
        profile.language = lang.rawValue
        profile.gender = selectedGender.rawValue
        profile.dailyGoalGrams = dailyGoal
        profile.weeklyGoalGrams = weeklyGoal
        profile.nicknameFlag = selectedFlag ?? "🇯🇵"
        profile.nicknameEmoji = selectedEmoji ?? "🌙"
        profile.nicknameAdjective = selectedAdjective ?? "ほろよい"
        profile.nicknameNoun = selectedNoun ?? "ペンギン"
        profile.onboardingCompleted = true

        try modelContext.save()
        appState.currentLanguage = lang
        // SwiftData の保存コミットと SwiftUI の再描画が同フレームで競合すると分岐が更新されない環境があるため、
        // 次のランループで完了フラグを立てる（「この相棒にする」後にホームへ切り替わらない」対策）。
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.25)) {
                appState.completeOnboarding()
            }
        }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
