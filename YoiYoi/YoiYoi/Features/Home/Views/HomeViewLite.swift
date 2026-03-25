import SwiftData
import SwiftUI

/// 白画面切り分け用の段階的 HomeView。依存を 1 つずつ足して、どこで壊れるか特定する。
/// Step 2: EnvironmentObject（言語表示まで）。
/// Step 3: SwiftData（最小 fetch 件数表示）まで追加していく。
struct HomeViewLite: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @State private var drinkRecordCount: Int = 0
    @State private var profileCount: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("HomeViewLite — Step 1")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Step 2: EnvironmentObject（言語: \(appState.currentLanguage.displayName)）")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Text("Step 3: SwiftData counts -> records=\(drinkRecordCount), profiles=\(profileCount)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
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
            AppLaunchDiagnostics.log("HomeViewLite.onAppear (Step 3: SwiftData)")

            // 依存増加の影響を最小化するため、最小限の fetch 件数だけ表示する。
            let drinkDescriptor = FetchDescriptor<DrinkRecord>()
            let drinks = (try? modelContext.fetch(drinkDescriptor)) ?? []
            let profileDescriptor = FetchDescriptor<UserProfile>()
            let profiles = (try? modelContext.fetch(profileDescriptor)) ?? []

            drinkRecordCount = drinks.count
            profileCount = profiles.count
        }
    }
}

#Preview {
    HomeViewLite()
        .environmentObject(AppState())
}
