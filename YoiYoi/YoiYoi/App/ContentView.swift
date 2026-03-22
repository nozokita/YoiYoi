import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showDrinkLog = false

    private var settingsTabTag: Int { FeatureFlags.isFeedEnabled ? 3 : 2 }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("ホーム", systemImage: "house.fill") }
                    .tag(0)

                CalendarView()
                    .tabItem { Label("カレンダー", systemImage: "calendar") }
                    .tag(1)

                if FeatureFlags.isFeedEnabled {
                    FeedView()
                        .tabItem { Label("みんな", systemImage: "globe.asia.australia.fill") }
                        .tag(2)
                }

                SettingsView()
                    .tabItem { Label("設定", systemImage: "gearshape.fill") }
                    .tag(settingsTabTag)
            }

            // 中央 FAB（DESIGN: 56pt）。bottom はタブバー上の暫定オフセット（後続で safeArea 連動）。
            VStack {
                Spacer()
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
                .padding(.bottom, AppSpacing.xl - AppSpacing.xs)
            }
            .allowsHitTesting(true)
        }
        .sheet(isPresented: $showDrinkLog) {
            DrinkLogSheet()
                .presentationDetents([.large])
        }
        .tint(AppColors.coralRed)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
