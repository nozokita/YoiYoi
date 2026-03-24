import SwiftData
import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
}

/// **段階実装** — タブ0 のみ `HomeView`、タブ1 はプレースホルダーのまま。
struct ContentView: View {
    @State private var selectedTab = 0

    private let otherTabSampleTitles = ["項目 A", "項目 B", "項目 C"]

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    tabTwoPlaceholder
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .background(AppColors.greyText.opacity(0.25))

            bottomBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
        .onAppear {
            AppLaunchDiagnostics.log("ContentView.onAppear（段階実装: tab0=HomeView） selectedTab=\(selectedTab)")
        }
    }

    private var tabTwoPlaceholder: some View {
        NavigationStack {
            List {
                ForEach(otherTabSampleTitles, id: \.self) { title in
                    NavigationLink {
                        otherDetailPlaceholder(title: title)
                    } label: {
                        Text(title)
                            .foregroundStyle(AppColors.charcoal)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColors.cream)
            .navigationTitle("その他")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func otherDetailPlaceholder(title: String) -> some View {
        VStack(spacing: 16) {
            Text("詳細（プレースホルダー）")
                .font(.headline)
                .foregroundStyle(AppColors.charcoal)
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(AppColors.coralRed)
            Text("次の段階でここに実データや編集 UI を載せる")
                .font(.subheadline)
                .foregroundStyle(AppColors.greyText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            barItem(index: 0, title: "ホーム", systemImage: "house.fill")
            barItem(index: 1, title: "その他", systemImage: "circle.grid.2x2.fill")
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(AppColors.cream)
    }

    private func barItem(index: Int, title: String, systemImage: String) -> some View {
        let on = selectedTab == index
        return Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: on ? .semibold : .regular))
                Text(title)
                    .font(.system(size: 11, weight: on ? .semibold : .regular))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(on ? AppColors.coralRed : AppColors.greyText)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .modelContainer(for: [DrinkRecord.self, UserProfile.self], inMemory: true)
}
