import SwiftData
import SwiftUI

/// Lean MVP オンボーディング: 言語 → 性別・目安 → コーチ → ホーム。
struct OnboardingContainerView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var vm = OnboardingViewModel()
    @State private var currentStep = 0
    @State private var saveErrorMessage: String?

    var body: some View {
        ZStack {
            AppGradients.onboardingFullScreen.ignoresSafeArea()
            VStack(spacing: 0) {
                Group {
                    switch currentStep {
                    case 0:
                        LanguageSelectView(vm: vm, displayLanguage: appState.currentLanguage) {
                            if let lang = vm.selectedLanguage {
                                appState.currentLanguage = lang
                            }
                            currentStep = 1
                        }
                    case 1:
                        GenderGoalView(
                            vm: vm,
                            language: vm.selectedLanguage ?? .ja,
                            onBack: { currentStep = 0 },
                            onContinue: { currentStep = 2 }
                        )
                    case 2:
                        CoachPersonalitySelectView(
                            vm: vm,
                            language: vm.selectedLanguage ?? .ja,
                            onBack: { currentStep = 1 },
                            onContinue: finishOnboarding
                        )
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                pageIndicator
                    .padding(.bottom, AppSpacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            AppLaunchDiagnostics.log("OnboardingContainerView.onAppear step=\(currentStep)")
        }
        .alert(AppCopy.onboardingSaveErrorTitle(appState.currentLanguage), isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button(AppCopy.commonOK(appState.currentLanguage), role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "")
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == currentStep ? AppColors.coralRed : AppColors.greyText.opacity(0.24))
                    .frame(width: index == currentStep ? 22 : 7, height: 7)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentStep)
    }

    private func finishOnboarding() {
        AppLaunchDiagnostics.log("OnboardingContainerView.finishOnboarding tapped")
        do {
            try vm.completeOnboarding(modelContext: modelContext, appState: appState)
        } catch {
            AppLaunchDiagnostics.log("OnboardingContainerView.finishOnboarding failed: \(error.localizedDescription)")
            if let e = error as? OnboardingCompletionError {
                saveErrorMessage = e.message(language: appState.currentLanguage)
            } else {
                saveErrorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AppState())
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
