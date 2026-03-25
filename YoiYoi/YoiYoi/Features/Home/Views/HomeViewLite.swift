import SwiftUI

/// 白画面切り分け用の段階的 HomeView。依存を 1 つずつ足して、どこで壊れるか特定する。
/// Step 1: EnvironmentObject なし、SwiftData なし、ScrollView なし。
struct HomeViewLite: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("HomeViewLite — Step 1")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("依存ゼロ（色背景＋Textのみ）")
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
            AppLaunchDiagnostics.log("HomeViewLite.onAppear (Step 1: 依存ゼロ)")
        }
    }
}

#Preview {
    HomeViewLite()
}
