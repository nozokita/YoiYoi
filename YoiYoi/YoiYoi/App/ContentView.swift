import SwiftData
import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
    /// `HomeView` / `HomeViewLite` など子ビューから飲酒記録シートを開く。
    static let openDrinkLogSheet = Notification.Name("YoiYoi.openDrinkLogSheet")
}

/// **段階実装** — タブ0 は `HomeView`、タブ1 はプレースホルダー。下端は **タブバー + 記録 FAB**（DESIGN.md）。
///
/// タブバーを `VStack` の下に兄弟で置くと内側の `ScrollView` に縦 0 が渡ることがあるため、
/// タブは **`safeAreaInset(edge: .bottom)`** に載せる。
///
/// **慎重に増やす**: 4タブ＋FAB へ一気に変えた環境で `HomeView` の下段 `ScrollView` が潰れた事例あり。
/// タブやバー構成を変えるときは **1変更ずつ** 入れ、毎回ホームでカードが表示されるか確認すること。
struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0
    @State private var showDrinkLogSheet = false

    private let otherTabSampleTitles = ["項目 A", "項目 B", "項目 C"]

    var body: some View {
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
        .background(AppColors.cream)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    drinkLogFAB
                    Spacer(minLength: 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
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
            AppLaunchDiagnostics.log("ContentView.onAppear（tab0=HomeView FAB） selectedTab=\(selectedTab)")
        }
        .onReceive(NotificationCenter.default.publisher(for: .openDrinkLogSheet)) { _ in
            // 同一ランループで `sheet` を立ち上げるとメインスレッドで固まる事例への回避（次フレームで表示）。
            DispatchQueue.main.async {
                showDrinkLogSheet = true
            }
        }
    }

    /// DESIGN.md「中央 FAB」— 記録シートを開く（`openDrinkLogSheet` と同じく次フレームで表示）。
    private var drinkLogFAB: some View {
        Button {
            DispatchQueue.main.async {
                showDrinkLogSheet = true
            }
        } label: {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.coralLight, AppColors.coralRed],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 56, height: 56)
                .shadow(color: AppColors.coralDeep.opacity(0.3), radius: 12, y: 4)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("飲み物を記録")
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
