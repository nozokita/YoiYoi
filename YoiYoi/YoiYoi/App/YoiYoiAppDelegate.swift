import UIKit

/// Firebase など UIKit ライフサイクルで必要な処理のみ。`@main` は `YoiYoiApp`（SwiftUI）側。
final class YoiYoiAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppLaunchDiagnostics.log("YoiYoiAppDelegate.didFinishLaunching（Firebase 前）")
        FirebaseBootstrap.configureIfNeeded()
        AppLaunchDiagnostics.log("YoiYoiAppDelegate.didFinishLaunching（Firebase 後）")
        return true
    }
}
