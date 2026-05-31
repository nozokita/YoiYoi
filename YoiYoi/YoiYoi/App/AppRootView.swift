import SwiftData
import SwiftUI

/// オンボーディング状態とローカル通知設定を起動時に復元する。
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            // UIHostingController が透明化してもウィンドウ越しに黒が見えないよう、最背面を必ず塗る
            AppColors.cream
                .ignoresSafeArea()

            Group {
                if appState.onboardingCompleted {
                    ContentView()
                        .environmentObject(appState)
                } else {
                    OnboardingContainerView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // `ObservableObject` の更新が分岐の再評価に乗らない環境対策（オンボ完了後にホームへ切り替え）
            .id(appState.onboardingCompleted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.light)
        .onAppear {
            AppLaunchDiagnostics.log(
                "AppRootView.onAppear onboardingCompleted=\(appState.onboardingCompleted) → \(appState.onboardingCompleted ? "ContentView" : "Onboarding")"
            )
            #if DEBUG
            DebugOnboarding.applyLaunchArgumentIfNeeded(modelContext: modelContext, appState: appState)
            #endif
            if !appState.onboardingCompleted {
                syncOnboardingFromSavedProfileIfNeeded()
            }
            NotificationService.applyCurrentSettings()
        }
    }

    /// SwiftData 上は完了済みなのに UserDefaults / AppState だけずれている場合のリカバリ（二重管理の取りこぼし対策）。
    private func syncOnboardingFromSavedProfileIfNeeded() {
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? modelContext.fetch(descriptor).first,
              profile.onboardingCompleted,
              !appState.onboardingCompleted
        else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            appState.completeOnboarding()
        }
    }
}
