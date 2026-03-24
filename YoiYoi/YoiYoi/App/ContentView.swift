import SwiftData
import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
}

/// `docs/IMPLEMENTATION_PLAN.md` **Phase 0** に相当するメインシェル。
/// - Home / Calendar /（`FeatureFlags.isFeedEnabled` 時のみ Feed）/ Settings
/// - 下部の自前タブバー + 中央 **FAB** → `DrinkLogSheet`
///
/// **実装メモ:** 計画文面は `TabView` だが、OS 差で中身が真っ白になる事例があるため **自前 `HStack` タブ**とする（仕様・画面構成は同じ）。
struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0
    @State private var showDrinkLog = false

    private var showsFeedTab: Bool { FeatureFlags.isFeedEnabled }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    CalendarView()
                case 2:
                    if showsFeedTab {
                        FeedView()
                    } else {
                        SettingsView()
                    }
                case 3:
                    SettingsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .background(AppColors.greyText.opacity(0.2))

            customTabBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
        .overlay(alignment: .bottom) {
            HStack {
                Spacer()
                Button {
                    showDrinkLog = true
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
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("飲酒を記録")
                Spacer()
            }
            .padding(.bottom, 72)
        }
        .tint(AppColors.coralRed)
        .sheet(isPresented: $showDrinkLog, onDismiss: {
            NotificationCenter.default.post(name: .drinkLogSheetDismissed, object: nil)
        }) {
            DrinkLogSheet()
                .environmentObject(appState)
                .presentationDetents([.large])
        }
        .onAppear {
            AppLaunchDiagnostics.log(
                "ContentView.onAppear（Phase0: tabs+FAB+DrinkLogSheet） selectedTab=\(selectedTab) feed=\(showsFeedTab)"
            )
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(index: 0, title: "ホーム", systemImage: "house.fill")
            tabItem(index: 1, title: "カレンダー", systemImage: "calendar")
            if showsFeedTab {
                tabItem(index: 2, title: "みんな", systemImage: "globe.asia.australia.fill")
                tabItem(index: 3, title: "設定", systemImage: "gearshape.fill")
            } else {
                tabItem(index: 2, title: "設定", systemImage: "gearshape.fill")
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(AppColors.cream)
    }

    private func tabItem(index: Int, title: String, systemImage: String) -> some View {
        let on = selectedTab == index
        return Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: on ? .semibold : .regular))
                Text(title)
                    .font(.system(size: 10, weight: on ? .semibold : .regular))
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
