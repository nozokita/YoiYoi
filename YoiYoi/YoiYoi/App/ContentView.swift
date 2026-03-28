import SwiftData
import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
    /// `HomeView` / `HomeViewLite` など子ビューから飲酒記録シートを開く。
    static let openDrinkLogSheet = Notification.Name("YoiYoi.openDrinkLogSheet")
}

/// **段階実装** — タブ0〜3 は `HomeView` / `CalendarView` / `FeedView` / 設定プレースホルダー。下端は **4等分タブバー + 記録 FAB**（中央スペーサーなし）。
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

    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                HomeView()
            case 1:
                CalendarView()
            case 2:
                FeedView()
            case 3:
                settingsTabRoot
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
            AppLaunchDiagnostics.log("ContentView.onAppear（4tabs+FAB） selectedTab=\(selectedTab)")
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

    private var settingsTabRoot: some View {
        NavigationStack {
            List {
                Section {
                    Text("アプリ設定は順次追加予定です")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.greyText)
                        .listRowBackground(AppColors.cream)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColors.cream)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            barItem(index: 0, title: "ホーム", systemImage: "house.fill")
            barItem(index: 1, title: "カレンダー", systemImage: "calendar")
            barItem(index: 2, title: "みんな", systemImage: "globe")
            barItem(index: 3, title: "設定", systemImage: "gearshape.fill")
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
