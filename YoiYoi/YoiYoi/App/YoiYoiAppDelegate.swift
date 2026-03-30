import UIKit
import UserNotifications

/// Firebase など UIKit ライフサイクルで必要な処理のみ。`@main` は `YoiYoiApp`（SwiftUI）側。
final class YoiYoiAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppLaunchDiagnostics.log("YoiYoiAppDelegate.didFinishLaunching（Firebase 前）")
        FirebaseBootstrap.configureIfNeeded()
        AppLaunchDiagnostics.log("YoiYoiAppDelegate.didFinishLaunching（Firebase 後）")
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension YoiYoiAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
