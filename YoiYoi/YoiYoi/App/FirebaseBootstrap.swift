import Foundation
import FirebaseCore

enum FirebaseBootstrap {
    /// `GoogleService-Info.plist` があるときだけ初期化（未配置でもビルド可能）。
    static func configureIfNeeded() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path)
        else { return }
        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure(options: options)
    }
}
