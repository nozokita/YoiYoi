import SwiftUI

/// Phase 4 で EULA〜ニックネームの5ステップに置き換え。Phase 0 はプレースホルダ。
struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 24) {
            Text("YoiYoi")
                .font(.largeTitle.bold())
            Text("オンボーディングは Phase 4 で実装")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("はじめる（仮）") {
                appState.completeOnboarding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    OnboardingContainerView()
        .environment(AppState())
}
