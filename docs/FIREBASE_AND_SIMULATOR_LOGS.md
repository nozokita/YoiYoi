# Firebase 警告と `load_eligibility_plist` について（白画面との関係）

## 結論（先に）

| ログ | 白画面の原因になりうるか |
|------|-------------------------|
| `I-COR000003` The default Firebase app has not yet been configured | **通常は NO**。設定漏れの**警告**であり、YoiYoi は未設定時は Auth/Firestore をガードして触らない設計。 |
| `load_eligibility_plist: Failed to open ... eligibility.plist` | **NO**。**シミュレーター OS 側**のメッセージで、アプリのコードや Firebase とは無関係。 |

白画面の典型原因は **CoreSimulator の不調・SwiftData ストア・SwiftUI の描画/環境** 側に多いです（README の「シミュレーターが真っ白」の項を参照）。

---

## 1. `load_eligibility_plist` について

- パスに `CoreSimulator/Devices/.../private/var/db/eligibilityd/eligibility.plist` と出るのは、**ゲスト OS（シミュレーター内 iOS）** が用意しないパスをシステムデーモンが読もうとしたときのログです。
- **実機では出ない／出方が違う**ことが多く、**アプリがクラッシュしたり UI が白くなる直接原因にはなりません**。
- 対処は「気にしない」か、シミュレーター **Erase**・Simulator 再起動でノイズが減ることがあります。

---

## 2. `I-COR000003`（Firebase 未 configure）について

### 何が起きているか

- `FirebaseApp.configure()` が一度も成功していないのに、SDK のどこかが **デフォルトの `FirebaseApp`** を前提にした処理をしたときに出ます。
- YoiYoi では `YoiYoiAppDelegate.didFinishLaunching` で `FirebaseBootstrap.configureIfNeeded()` を呼び、**`GoogleService-Info.plist` がメインバンドルに無い場合は `configure` 自体をスキップ**します（[`FirebaseBootstrap.swift`](../YoiYoi/YoiYoi/App/FirebaseBootstrap.swift)、[`YoiYoiAppDelegate.swift`](../YoiYoi/YoiYoi/App/YoiYoiAppDelegate.swift)）。

### リポジトリの状態

- このリポジトリには **`GoogleService-Info.plist` が含まれていません**（秘密情報のため想定どおり）。ローカルで Xcode に追加している場合でも、次を満たさないと **バンドルに入らず** `configure` が走りません。
  - 対象 **Target Membership** にチェック
  - **Build Phases → Copy Bundle Resources** に含まれる

### 白画面との関係

- この警告は **コンソールへのログ**が主で、**それだけでウィンドウ全体が真っ白になることは普通はありません**。
- ただし **plist が無い／ターゲットに入っていない**と、匿名ログインや Firestore 同期は意図どおり動きません（アプリ本体のオンボーディングや SwiftData は別経路なので、多くの画面は動く想定）。

### 対処

1. Firebase コンソールから `GoogleService-Info.plist` を取得する  
2. Xcode で YoiYoi ターゲットに追加し、**Copy Bundle Resources** を確認する  
3. クリーンビルドして再実行し、警告が消えるか確認する  

---

## 3. 白画面を切り分けるときのチェックリスト

1. Xcode **Console** に **赤いクラッシュログ**がないか（Firebase 警告は黄色でも続行できることが多い）  
2. **Simulator → Device → Erase All Content and Settings**  
3. **Product → Clean Build Folder**  
4. アプリ側で SwiftData 初期化に失敗している場合は「データを開けませんでした」画面が出る実装になっているか確認（[`YoiYoiApp.swift`](../YoiYoi/YoiYoi/App/YoiYoiApp.swift) 内の `YoiYoiModelStoreFailureView`）  

---

## 参考リンク

- [Firebase iOS セットアップ（initialize）](https://firebase.google.com/docs/ios/setup#initialize_firebase_in_your_app)
