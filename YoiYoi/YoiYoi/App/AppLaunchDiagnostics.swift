import Foundation
import os
import SwiftUI

// MARK: - 全ビルド共通（Console / Console.app で検索可能）

private let appLaunchOSLog = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "YoiYoi",
    category: "Launch"
)

/// 白画面の切り分け用。`os_log` に必ず出し、DEBUG では画面オーバーレイにも溜める。
enum AppLaunchDiagnostics {
    static func log(_ message: String) {
        appLaunchOSLog.info("\(message, privacy: .public)")
        #if DEBUG
        print("[YoiYoi Launch] \(message)")
        DebugLaunchLog.shared.append(message)
        #endif
    }

}

// MARK: - DEBUG のみ：画面上のログ（最上部の赤帯で必ず視認できるようにする）

#if DEBUG
final class DebugLaunchLog: ObservableObject {
    static let shared = DebugLaunchLog()

    @Published private(set) var messages: [String] = []
    private let maxLines = 50

    func append(_ raw: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let line = "\(formatter.string(from: Date())) \(raw)"
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            messages.append(line)
            if messages.count > maxLines {
                messages.removeFirst(messages.count - maxLines)
            }
        }
    }
}

struct DebugLaunchOverlay: View {
    @ObservedObject private var log = DebugLaunchLog.shared

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("YoiYoi DEBUG — この赤帯が見えれば SwiftUI は最前面まで描画できている")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(Array(log.messages.suffix(6).enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.95))
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
                .frame(maxHeight: 36)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red)

            Spacer(minLength: 0)
        }
        .allowsHitTesting(false)
    }
}
#else
struct DebugLaunchOverlay: View {
    var body: some View { EmptyView() }
}
#endif
