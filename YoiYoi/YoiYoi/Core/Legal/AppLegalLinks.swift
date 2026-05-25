import Foundation

/// 法務・ストア申請用の外部リンク。GitHub Pages（`docs/`）をソースにする。
/// リポジトリ: Settings → Pages → Build and deployment: **Deploy from a branch** → **main** → **/docs**
enum AppLegalLinks {
    /// `https://<owner>.github.io/<repo>/`
    private static let pagesRoot = "https://nozokita.github.io/YoiYoi"

    static var privacyPolicyURL: URL {
        URL(string: "\(pagesRoot)/legal/privacy.html")!
    }
}
