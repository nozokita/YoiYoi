import UIKit
import UserNotifications

/// 通知をアプリ前面でも表示するための UIKit delegate。`@main` は `YoiYoiApp` 側。
final class YoiYoiAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppLaunchDiagnostics.log("YoiYoiAppDelegate.didFinishLaunching")
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
