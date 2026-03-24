import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6 保存後も利用）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
}

/// **段階実装** — 1 ステップずつ足す。
/// - step1: クリーム + カウンタ
/// - step2 (B): 下の「タブ風」2択（中身はプレースホルダーのみ。システム `TabView` は使わない）
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var tapCount = 0

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case 0:
                    stepOnePanel
                case 1:
                    tabTwoPlaceholder
                default:
                    stepOnePanel
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
            AppLaunchDiagnostics.log("ContentView.onAppear（段階実装 step2: tab shell） selectedTab=\(selectedTab)")
        }
    }

    /// step1 の内容（そのまま残す）
    private var stepOnePanel: some View {
        VStack(spacing: 24) {
            Text("YoiYoi")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.charcoal)

            Text("HELLO WORLD")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.coralRed)

            Text("ステップ2: 下のバーで切り替え（ここはタブ0）")
                .font(.subheadline)
                .foregroundStyle(AppColors.greyText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                tapCount += 1
            } label: {
                Text("タップした回数: \(tapCount)")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(AppColors.coralRed, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// タブ1は `Text` のみ（本番画面はまだ載せない）
    private var tabTwoPlaceholder: some View {
        VStack(spacing: 16) {
            Text("タブ 1")
                .font(.title2.bold())
                .foregroundStyle(AppColors.charcoal)
            Text("ここに次の機能を足していく")
                .font(.body)
                .foregroundStyle(AppColors.greyText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}
