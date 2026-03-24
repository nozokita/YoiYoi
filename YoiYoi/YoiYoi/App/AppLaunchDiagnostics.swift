import Foundation
import os

private let appLaunchOSLog = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "YoiYoi",
    category: "Launch"
)

/// 起動・画面切り替えの切り分け用。`os_log` と（DEBUG 時）`print` のみ。
enum AppLaunchDiagnostics {
    static func log(_ message: String) {
        appLaunchOSLog.info("\(message, privacy: .public)")
        #if DEBUG
        print("[YoiYoi Launch] \(message)")
        #endif
    }
}
