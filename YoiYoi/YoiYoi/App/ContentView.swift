import SwiftData
import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
    /// 子ビューから飲酒記録シートを開く。
    static let openDrinkLogSheet = Notification.Name("YoiYoi.openDrinkLogSheet")
    /// `UserProfile` の目標・ニックネーム等を更新したあと、ホーム等が再集計するためのフック。
    static let userProfileDidChange = Notification.Name("YoiYoi.userProfileDidChange")
    /// 飲み会モードの開始・更新・終了を各画面へ反映する。
    static let sessionDidChange = Notification.Name("YoiYoi.sessionDidChange")
}

/// タブ0〜2 は `HomeView` / `CalendarView` / `SettingsRootView`。下端は **3等分タブバー + 記録 FAB**。
/// FAB は **`safeAreaInset` 外の `overlay`**（インセット内は高さ確保用の `Color.clear` のみ）。`ZStack` 化した事例で `HomeView` の `ScrollView` が潰れたため。
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

    /// 旧 HStack+FAB+padding（8+56+16）と同じ確保高さ。インセット構造は `VStack { 透明帯 / Divider / bar }` の3段のまま。
    private enum TabChrome {
        static let fabSlotHeight: CGFloat = 80
        static let dividerHeight: CGFloat = 1
        /// `bottomBar` の概算（padding 10+8 + アイコン行）
        static let tabBarHeight: CGFloat = 54

        /// 画面下端から FAB の**底辺**までの距離（`position` 用）。
        static func distanceFromBottomToFabBottom(safeBottom: CGFloat) -> CGFloat {
            safeBottom + tabBarHeight + dividerHeight + fabSlotHeight / 2 - 28
        }
    }

    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                HomeView()
            case 1:
                CalendarView()
            case 2:
                SettingsRootView()
            default:
                HomeView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: TabChrome.fabSlotHeight)
                Divider()
                    .background(AppColors.hairline)
                bottomBar
            }
            .background(AppColors.surfaceElevated)
            .shadow(color: AppColors.darkBg.opacity(0.06), radius: 18, y: -4)
        }
        /// `GeometryReader` が提案サイズを食い潰して子の `ScrollView` に縦 0 が渡る事例への対策で、オーバーレイ全体を親と同じ無限領域に固定する。
        .overlay {
            GeometryReader { geo in
                let d = TabChrome.distanceFromBottomToFabBottom(safeBottom: geo.safeAreaInsets.bottom)
                let fabCenterY = geo.size.height - d - 28
                ZStack {
                    Color.clear
                        .allowsHitTesting(false)
                        .frame(width: geo.size.width, height: geo.size.height)
                    drinkLogFAB
                        .position(x: geo.size.width / 2, y: fabCenterY)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(true)
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
            AppLaunchDiagnostics.log("ContentView.onAppear（3tabs+FAB overlay） selectedTab=\(selectedTab)")
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
                        colors: [AppColors.coralRed, AppColors.coralDeep],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 58, height: 58)
                .overlay {
                    Circle()
                        .stroke(AppColors.pureWhite.opacity(0.45), lineWidth: 1)
                }
                .shadow(color: AppColors.darkBg.opacity(0.16), radius: 18, y: 8)
                .shadow(color: AppColors.coralDeep.opacity(0.20), radius: 12, y: 4)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppCopy.fabLogDrink(appState.currentLanguage))
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            barItem(index: 0, title: AppCopy.tabHome(appState.currentLanguage), icon: .chart)
            barItem(index: 1, title: AppCopy.tabCalendar(appState.currentLanguage), icon: .calendar)
            barItem(index: 2, title: AppCopy.tabSettings(appState.currentLanguage), icon: .settings)
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(AppColors.surfaceElevated)
    }

    private func barItem(index: Int, title: String, icon: YoiYoiIcon) -> some View {
        let on = selectedTab == index
        return Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                SVGIcon(icon: icon, size: 20, color: on ? AppColors.coralRed : AppColors.greyText)
                Text(title)
                    .font(.system(size: 11, weight: on ? .semibold : .regular))
            }
            .foregroundStyle(on ? AppColors.coralRed : AppColors.greyText)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(on ? AppColors.coralLight.opacity(0.65) : Color.clear)
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .modelContainer(for: [DrinkRecord.self, UserProfile.self, DrinkingSession.self, QuickDrinkPreset.self], inMemory: true)
}
