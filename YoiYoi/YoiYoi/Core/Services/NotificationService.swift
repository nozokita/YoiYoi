import Foundation
import UserNotifications

/// ローカル通知（飲酒記録リマインダー）の管理。
/// UserDefaults に設定を保存し、起動時や設定変更時にスケジュールし直す。
enum NotificationService {
    private enum Keys {
        static let enabled = "notifications.enabled"
        static let hour = "notifications.hour"
        static let minute = "notifications.minute"
    }

    struct Settings {
        var enabled: Bool
        var hour: Int
        var minute: Int

        static let `default` = Settings(enabled: false, hour: 21, minute: 0)
    }

    static func currentSettings() -> Settings {
        let enabled = UserDefaults.standard.bool(forKey: Keys.enabled)
        let hour = UserDefaults.standard.object(forKey: Keys.hour) as? Int ?? Settings.default.hour
        let minute = UserDefaults.standard.object(forKey: Keys.minute) as? Int ?? Settings.default.minute
        return Settings(enabled: enabled, hour: hour, minute: minute)
    }

    static func saveSettings(_ settings: Settings) {
        UserDefaults.standard.set(settings.enabled, forKey: Keys.enabled)
        UserDefaults.standard.set(settings.hour, forKey: Keys.hour)
        UserDefaults.standard.set(settings.minute, forKey: Keys.minute)
    }

    /// アプリ起動時などに現在の設定に基づき通知を張り直す。
    static func applyCurrentSettings() {
        let settings = currentSettings()
        Task {
            await refreshSchedule(settings: settings)
        }
    }

    /// ユーザー操作から呼ぶ。設定を保存し、スケジュールを更新する。
    static func update(enabled: Bool, hour: Int, minute: Int) {
        let s = Settings(enabled: enabled, hour: hour, minute: minute)
        saveSettings(s)
        Task {
            await refreshSchedule(settings: s)
        }
    }

    private static func refreshSchedule(settings: Settings) async {
        let center = UNUserNotificationCenter.current()
        await center.removePendingNotificationRequests(withIdentifiers: ["daily_drink_reminder"])

        guard settings.enabled else { return }

        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "YoiYoi"
        content.body = "今日は飲んだ？ 記録しておこう 🍺"
        content.sound = .default

        var date = DateComponents()
        date.hour = settings.hour
        date.minute = settings.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_drink_reminder",
            content: content,
            trigger: trigger
        )
        do {
            try await center.add(request)
        } catch {
            // ログだけ残して黙って失敗
            AppLaunchDiagnostics.log("NotificationService.schedule error: \\(error.localizedDescription)")
        }
    }

    private static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let status = await center.notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }
}

