import Foundation

/// 法務・ストア申請用の外部リンク。**本番リリース前に実際のプライバシーポリシー URL に差し替えること。**
enum AppLegalLinks {
    /// プライバシーポリシー（Web）。未用意の間はリポジトリを指すプレースホルダ。
    static var privacyPolicyURL: URL {
        URL(string: "https://github.com/nozokita/YoiYoi")!
    }
}
