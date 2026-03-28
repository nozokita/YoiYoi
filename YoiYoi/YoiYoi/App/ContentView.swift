import SwiftData
import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
    /// `HomeViewLite` など子ビューから飲酒記録シートを開く。
    static let openDrinkLogSheet = Notification.Name("YoiYoi.openDrinkLogSheet")
}

/// **段階実装** — タブ0 は `homeSmoke`（表示確認）、タブ1 はプレースホルダー。
///
/// タブバーを `VStack` の下に兄弟で置くと内側の `ScrollView` に縦 0 が渡ることがあるため、
/// タブは **`safeAreaInset(edge: .bottom)`** に載せる。
struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0
    @State private var showDrinkLogSheet = false

    private let otherTabSampleTitles = ["項目 A", "項目 B", "項目 C"]

    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                HomeViewLite()
            case 1:
                tabTwoPlaceholder
            default:
                HomeViewLite()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider()
                    .background(AppColors.greyText.opacity(0.25))
                bottomBar
            }
            .background(AppColors.cream)
        }
        .sheet(isPresented: $showDrinkLogSheet, onDismiss: {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .drinkLogSheetDismissed, object: nil)
            }
        }) {
            DrinkLogSheet()
                .environmentObject(appState)
                .presentationDetents([.large])
        }
        .onAppear {
            AppLaunchDiagnostics.log("ContentView.onAppear（tab0=HomeViewLite） selectedTab=\(selectedTab)")
        }
        .onReceive(NotificationCenter.default.publisher(for: .openDrinkLogSheet)) { _ in
            // 同一ランループで `sheet` を立ち上げるとメインスレッドで固まる事例への回避（次フレームで表示）。
            DispatchQueue.main.async {
                showDrinkLogSheet = true
            }
        }
    }

    /// スモークテスト: HomeView 接続前に「タブ0 で色付きビューが見えるか」を確認するだけ。
    private var homeSmoke: some View {
        VStack(spacing: 20) {
            Text("HOME SMOKE TEST")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text("これが見えればタブ0は生きている")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Button {
                showDrinkLogSheet = true
            } label: {
                Text("シートを開く（プレースホルダー）")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppColors.coralLight, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.coralRed)
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
