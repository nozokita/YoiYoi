import SwiftData
import SwiftUI

/// SPEC「オンボーディング（5ステップ）」: EULA → 言語 → 性別・目標 → ニックネーム → ホーム。
/// EULA はページインジケーターに含めない（言語 / 性別 / ニックネームの 3 ドット）。
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
                        EULAView(vm: vm, displayLanguage: appState.currentLanguage) {
                            currentStep = 1
                        }
                    case 1:
                        LanguageSelectView(vm: vm) {
                            if let lang = vm.selectedLanguage {
                                appState.currentLanguage = lang
                            }
                            currentStep = 2
                        }
                    case 2:
                        GenderGoalView(
                            vm: vm,
                            language: vm.selectedLanguage ?? .ja,
                            onBack: { currentStep = 1 },
                            onContinue: { currentStep = 3 }
                        )
                    case 3:
                        NicknameSelectView(
                            vm: vm,
                            language: vm.selectedLanguage ?? .ja,
                            onBack: { currentStep = 2 },
                            onComplete: finishOnboarding
                        )
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if currentStep >= 1, currentStep <= 3 {
                    pageIndicator
                        .padding(.bottom, AppSpacing.lg)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            AppLaunchDiagnostics.log("OnboardingContainerView.onAppear step=\(currentStep)")
        }
        .alert("保存エラー", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "")
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index == currentStep - 1 ? AppColors.coralRed : AppColors.greyText.opacity(0.35))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private func finishOnboarding() {
        do {
            try vm.completeOnboarding(modelContext: modelContext, appState: appState)
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AppState())
        .modelContainer(for: UserProfile.self, inMemory: true)
}
