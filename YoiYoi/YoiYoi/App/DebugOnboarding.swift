import Foundation
import SwiftData

#if DEBUG
/// **DEBUG のみ** — オンボーディングをいつでも確認する。
///
/// ## 使い方
/// 1. **Xcode → Edit Scheme → Run → Arguments** に `-YoiYoiOnboarding` を追加（1 回の起動で先頭からオンボへ）。
/// 2. **設定タブ**最下部の「Debug」セクションのボタン（メインアプリから即オンボへ戻る）。
///
/// `UserProfile` が無い場合は `AppState` と UserDefaults のみ戻し、プロフィール側はスキップする。
@MainActor
enum DebugOnboarding {
    static let launchArgument = "-YoiYoiOnboarding"

    private static var didApplyLaunchArgument = false

    /// 起動直後に 1 度だけ、`AppRootView.onAppear` から呼ぶ。
    static func applyLaunchArgumentIfNeeded(modelContext: ModelContext, appState: AppState) {
        guard ProcessInfo.processInfo.arguments.contains(launchArgument) else { return }
        guard !didApplyLaunchArgument else { return }
        didApplyLaunchArgument = true
        resetForReplay(modelContext: modelContext, appState: appState, fromEULA: true)
        AppLaunchDiagnostics.log("DebugOnboarding: applied launch argument \(launchArgument)")
    }

    /// オンボを再度表示できる状態にする。
    /// - Parameters:
    ///   - fromEULA: `true` なら EULA からやり直し（利用規約の再読込用）。`false` なら完了フラグのみ戻す。
    static func resetForReplay(modelContext: ModelContext, appState: AppState, fromEULA: Bool) {
        appState.resetOnboardingForDebug()
        let desc = FetchDescriptor<UserProfile>()
        guard let p = try? modelContext.fetch(desc).first else { return }
        p.onboardingCompleted = false
        if fromEULA {
            p.eulaAccepted = false
            p.eulaAcceptedAt = nil
        }
        try? modelContext.save()
    }
}
#endif
