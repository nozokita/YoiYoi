import Foundation
import UserNotifications

/// ローカル通知（飲酒記録リマインダー）の管理。
/// UserDefaults に設定を保存し、起動時や設定変更時にスケジュールし直す。
enum NotificationService {
    static let maximumHydrationReminders = 10
    private static let dailyReminderID = "daily_drink_reminder"
    private static let hydrationReminderPrefix = "session_hydration_"

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
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])

        guard settings.enabled else { return }

        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "YoiYoi"
        content.body = "今日のペースを記録して振り返ろう"
        content.sound = .default

        var date = DateComponents()
        date.hour = settings.hour
        date.minute = settings.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(
            identifier: dailyReminderID,
            content: content,
            trigger: trigger
        )
        do {
            try await center.add(request)
        } catch {
            // ログだけ残して黙って失敗
            AppLaunchDiagnostics.log("NotificationService.schedule error: \(error.localizedDescription)")
        }
    }

    static func hydrationReminderDates(
        startingAt startTime: Date,
        intervalMinutes: Int,
        count: Int = maximumHydrationReminders,
        calendar: Calendar = .current
    ) -> [Date] {
        guard intervalMinutes > 0, count > 0 else { return [] }
        return (1...min(count, maximumHydrationReminders)).compactMap { index in
            calendar.date(byAdding: .minute, value: intervalMinutes * index, to: startTime)
        }
    }

    static func scheduleHydrationReminders(
        sessionID: UUID,
        startingAt startTime: Date,
        intervalMinutes: Int,
        language: SupportedLanguage
    ) async {
        let center = UNUserNotificationCenter.current()
        cancelHydrationReminders(sessionID: sessionID)
        guard await requestAuthorizationIfNeeded() else { return }

        for (index, date) in hydrationReminderDates(startingAt: startTime, intervalMinutes: intervalMinutes).enumerated() {
            let delay = max(date.timeIntervalSinceNow, 1)
            let content = UNMutableNotificationContent()
            content.title = "YoiYoi"
            content.body = AppCopy.notificationHydrationBody(language)
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            let request = UNNotificationRequest(
                identifier: hydrationIdentifier(sessionID: sessionID, index: index),
                content: content,
                trigger: trigger
            )
            do {
                try await center.add(request)
            } catch {
                AppLaunchDiagnostics.log("NotificationService.hydration error: \(error.localizedDescription)")
            }
        }
    }

    static func cancelHydrationReminders(sessionID: UUID) {
        let identifiers = (0..<maximumHydrationReminders).map {
            hydrationIdentifier(sessionID: sessionID, index: $0)
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private static func hydrationIdentifier(sessionID: UUID, index: Int) -> String {
        "\(hydrationReminderPrefix)\(sessionID.uuidString)_\(index)"
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
