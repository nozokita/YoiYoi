import SwiftUI

/// 白画面切り分け用の段階的 HomeView。依存を 1 つずつ足して、どこで壊れるか特定する。
/// Step 2: EnvironmentObject（言語表示まで）。以降さらに依存を追加していく。
struct HomeViewLite: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("HomeViewLite — Step 1")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Step 2: EnvironmentObject（言語: \(appState.currentLanguage.displayName)）")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Text("これが見えれば ContentView → 子ビュー接続は正常")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.coralRed)
        .onAppear {
            AppLaunchDiagnostics.log("HomeViewLite.onAppear (Step 2: EnvironmentObject)")
        }
    }
}

#Preview {
    HomeViewLite()
        .environmentObject(AppState())
}
