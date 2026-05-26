import SwiftData
import SwiftUI

/// SwiftUI 標準の `WindowGroup` でウィンドウを構成する。
/// `ModelContainer` は **`init()` で同期的に**用意する（`.task` + `ProgressView` だと完了前に UI がスピナーのまま止まる事例がある）。
@main
struct YoiYoiApp: App {
    @UIApplicationDelegateAdaptor(YoiYoiAppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    private let launchRoot: LaunchRoot

    private enum LaunchRoot {
        case minimal
        case main(ModelContainer)
        case storeFailed(Error)
    }

    init() {
        AppLaunchDiagnostics.log("YoiYoiApp.init 開始")
        if ProcessInfo.processInfo.arguments.contains("-YoiYoiMinimal") {
            launchRoot = .minimal
            AppLaunchDiagnostics.log("YoiYoiApp.init — YoiYoiMinimal（SwiftData なし）")
            return
        }
        let schema = Schema([
            DrinkRecord.self,
            UserProfile.self,
            DrinkingSession.self,
            QuickDrinkPreset.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            AppLaunchDiagnostics.log("YoiYoiApp.init — ModelContainer 作成成功")
            launchRoot = .main(container)
        } catch {
            AppLaunchDiagnostics.log("YoiYoiApp.init — ModelContainer 失敗: \(error.localizedDescription)")
            launchRoot = .storeFailed(error)
        }
    }

    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear {
                    AppLaunchDiagnostics.log("WindowGroup ルート onAppear")
                }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        switch launchRoot {
        case .minimal:
            YoiYoiMinimalLaunchView()
        case .main(let container):
            AppRootView()
                .environmentObject(appState)
                .modelContainer(container)
        case .storeFailed(let error):
            YoiYoiModelStoreErrorView(error: error)
        }
    }
}

// MARK: - 起動切り分け用

private struct YoiYoiMinimalLaunchView: View {
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            Text("YoiYoi MINIMAL\n(-YoiYoiMinimal)")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .font(.title.bold())
        }
    }
}

private struct YoiYoiModelStoreErrorView: View {
    let error: Error

    var body: some View {
        VStack(spacing: 20) {
            Text("データを開けませんでした")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text(
                "シミュレーターなら Device → Erase All Content and Settings、\n"
                    + "実機ならアプリの削除と再インストールを試してください。"
            )
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
    }
}
