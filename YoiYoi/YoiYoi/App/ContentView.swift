import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6 保存後も利用）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
}

/// **段階実装** — 1 ステップずつ足す（前の本番 UI をまとめて戻さない）。
/// 現在: ステップ 1 … クリーム背景 + タイトル + カウンタ 1 個（`@State` の動作確認）。
struct ContentView: View {
    @State private var tapCount = 0

    var body: some View {
        ZStack {
            AppColors.cream
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("YoiYoi")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.charcoal)

                Text("HELLO WORLD")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.coralRed)

                Text("ステップ1: タップで数が増えれば状態更新OK")
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
        }
        .onAppear {
            AppLaunchDiagnostics.log("ContentView.onAppear（段階実装 step1: cream + counter）")
        }
    }
}

#Preview {
    ContentView()
}
