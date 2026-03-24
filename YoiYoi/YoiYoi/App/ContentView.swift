import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6 保存後も利用）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
}

/// **段階実装用の土台**（本番 UI はここに少しずつ足す。一度壊れた経路を一括で戻さない）。
struct ContentView: View {
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("HELLO WORLD")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(Color.white)
                Text("描画確認用の最小画面")
                    .font(.headline)
                    .foregroundStyle(Color.white)
            }
        }
        .onAppear {
            AppLaunchDiagnostics.log("ContentView.onAppear（Hello World 段階実装）")
        }
    }
}

#Preview {
    ContentView()
}
