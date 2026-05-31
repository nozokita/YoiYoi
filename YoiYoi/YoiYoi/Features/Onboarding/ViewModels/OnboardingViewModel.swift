import Foundation
import Observation
import SwiftData

enum OnboardingCompletionError: LocalizedError {
    case languageNotSelected

    func message(language: SupportedLanguage) -> String {
        AppCopy.onboardingErrorLanguageNotSelected(language)
    }

    var errorDescription: String? {
        AppCopy.onboardingErrorLanguageNotSelected(.ja)
    }
}

enum OnboardingGender: String, CaseIterable, Sendable {
    case male
    case female
    case custom
}

/// 言語、目安、ローカルコーチ設定を端末内の `UserProfile` へ保存する。
@Observable
@MainActor
final class OnboardingViewModel {
    var selectedLanguage: SupportedLanguage?
    var selectedGender: OnboardingGender = .male
    var selectedPersonality: CoachPersonality = .friendly
    var dailyGoal: Double = 25
    var weeklyGoal: Double = 175

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
        dailyGoal = (dailyGoal + delta).clamped(to: 5...120)
    }

    func adjustWeeklyGoal(by delta: Double) {
        weeklyGoal = (weeklyGoal + delta).clamped(to: 35...980)
    }

    func completeOnboarding(modelContext: ModelContext, appState: AppState) throws {
        guard let lang = selectedLanguage else { throw OnboardingCompletionError.languageNotSelected }

        let profiles = try modelContext.fetch(FetchDescriptor<UserProfile>())
        let profile = profiles.first ?? UserProfile()
        if profiles.isEmpty {
            modelContext.insert(profile)
        }

        profile.language = lang.rawValue
        profile.gender = selectedGender.rawValue
        profile.dailyGoalGrams = dailyGoal
        profile.weeklyGoalGrams = weeklyGoal
        profile.aiCoachPersonality = selectedPersonality.rawValue
        profile.onboardingCompleted = true

        try modelContext.save()
        AppLaunchDiagnostics.log("OnboardingViewModel.completeOnboarding — profile save succeeded")
        appState.currentLanguage = lang
        appState.completeOnboarding()
        AppLaunchDiagnostics.log("OnboardingViewModel.completeOnboarding — switched to home")
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
