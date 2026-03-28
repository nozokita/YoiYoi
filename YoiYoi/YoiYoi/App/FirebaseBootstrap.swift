import Foundation
import FirebaseCore

enum FirebaseBootstrap {
    /// バンドルに plist があり `FirebaseApp.configure()` 済みのときだけ true（Firebase API を呼ぶ前の共通ガード）。
    static var isFirebaseUsable: Bool {
        Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil
            && FirebaseApp.app() != nil
    }

    /// `GoogleService-Info.plist` がメインバンドルにあるときだけ初期化（未配置でもビルド可能）。
    ///
    /// **I-COR000003 が出る主な理由**: plist がバンドルに入っておらず `configure` がスキップされている、
    /// または別モジュールが起動直後に Firebase を触っている。白画面の直接原因ではないことが多い（`docs/FIREBASE_AND_SIMULATOR_LOGS.md` 参照）。
    static func configureIfNeeded() {
        guard FirebaseApp.app() == nil else { return }

        // `url(forResource:)` の方がサブディレクトリやビルド差分に強いことがある
        guard Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil else {
            AppLaunchDiagnostics.log(
                "FirebaseBootstrap: GoogleService-Info.plist がバンドルにない → configure スキップ（Firebase 無効・I-COR000003 の可能性）"
            )
            // plist 未配置時はコンソールノイズを多少抑える（完全には止まらない場合あり）
            FirebaseConfiguration.shared.setLoggerLevel(.error)
            return
        }

        FirebaseApp.configure()
        AppLaunchDiagnostics.log("FirebaseBootstrap: FirebaseApp.configure() 完了")
    }
}
