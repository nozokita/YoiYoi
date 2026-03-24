# 真っ白なシミュレーター画面のデバッグ手順

## 原因として多かったもの（YoiYoi での対応）

- **システム `TabView` + `UITabBar.appearance()`** の組み合わせで **ログだけ出て中身が真っ白**になることがある → **`TabView` を廃止し自前タブ**（[`ContentView.swift`](../YoiYoi/YoiYoi/App/ContentView.swift)）に変更済み。
- **起動は SwiftUI 標準** … **`@main` は [`YoiYoiApp.swift`](../YoiYoi/YoiYoi/App/YoiYoiApp.swift)** の `WindowGroup`。Firebase などは [`YoiYoiAppDelegate.swift`](../YoiYoi/YoiYoi/App/YoiYoiAppDelegate.swift) を **`@UIApplicationDelegateAdaptor`** で接続（手動 `UIWindow` / 専用 `SceneDelegate` は使わない。ログは出るのに真っ白になる事例の回避）。
- **ルート直下の `GeometryReader` + `ScrollView`** … 親（例: `ContentView` の `VStack`）から **高さ 0** が提案されると **`ScrollView` ごと潰れ**、ログは出るのに真っ白になることがある。ホーム／カレンダー／フィードのヒーロー高は [`WaveHeroLayout.swift`](../YoiYoi/YoiYoi/Core/Utilities/WaveHeroLayout.swift) の **`UIScreen.main.bounds` ベース**で決め、`GeometryReader` は使わない。
- **`VStack { ScrollView…; 固定タブバー }` のメインシェル** … 上段だけ `frame(maxHeight: .infinity)` でも、**タブバーを兄弟に置く**と環境によって **ScrollView に縦 0 が渡る**ことがある。対策のひとつ: メインに **`safeAreaInset(edge: .bottom)`** でタブを載せる。
- **`onAppear` は出るのに真っ白** … シェルは生きているが **子画面（例: `HomeView`）の中身**が描画されていない可能性。グラデ＋`clipShape`、ネストした `ScrollView`、`TimelineView` などを **1ブロックずつ外して**切り分ける。
- **背面のクリーム** … [`AppRootView`](../YoiYoi/YoiYoi/App/AppRootView.swift) の **最背面に `AppColors.cream.ignoresSafeArea()`** と **`preferredColorScheme(.light)`** を維持。
- **起動引数**（Edit Scheme → Run → Arguments）  
  - **`-YoiYoiMinimal`** … SwiftData / `AppRootView` なしの **真っ赤 MINIMAL**（[`YoiYoiApp.swift`](../YoiYoi/YoiYoi/App/YoiYoiApp.swift) が分岐）。**SwiftUI のウィンドウが描画できるか**の切り分け用。

---

## 初心者向け：Scheme が Debug か確認して Run する（画面の場所つき）

### ステップ A — プロジェクトを開く

1. **Finder** で `YoiYoi.xcodeproj` をダブルクリックする（場所の例: `YoiYoi` フォルダの中の `YoiYoi/YoiYoi.xcodeproj`）。
2. **Xcode** が開き、左にファイル一覧、上にツールバーが見えます。

### ステップ B — 「Scheme」とは何か

- **Scheme（スキーム）** = 「どのアプリを」「どんな設定（Debug / Release）で」動かすかのセットです。
- 起動ログは **Debug ビルド**では Xcode コンソールに **`[YoiYoi Launch]`** として出ます（画面上部の赤帯オーバーレイは廃止済み）。

### ステップ C — Scheme を確認・変更する

1. Xcode ウィンドウ **一番上のツールバー** を見ます（再生ボタン ▶ の少し左）。
2. **アプリ名と端末名が並んだドロップダウン** があります。  
   - 例: `YoiYoi` の右に `>` や `iPhone 16 Pro` などが続いている領域。  
   - 左側の **アプリ名部分（多くの場合 `YoiYoi`）だけ** が Scheme です。
3. その **左側（アプリ名）** をクリックします。
4. メニューが開いたら、一番下付近の **「Edit Scheme…」**（日本語 Xcode なら **「スキームを編集…」**）を選びます。
5. 左の一覧で **「Run」**（実行）が青く選ばれていることを確認します。
6. 上のタブで **「Info」** を開きます。
7. **「Build Configuration」**（ビルド構成）が **`Debug`** になっているか見ます。  
   - `Release` になっていたら、クリックして **`Debug`** に変更します。
8. 右下の **「Close」**（閉じる）で閉じます。

### ステップ D — シミュレーターを選ぶ

1. もう一度ツールバーの **Scheme の右側**（端末名のドロップダウン）をクリックします。
2. **「iPhone 16 Pro」** など、使いたい **シミュレーター** を選びます。

### ステップ E — 実行（Run）

1. キーボード **`⌘ + R`**（Command + R）を押す、または左上の **▶（Run）** をクリックします。
2. しばらくすると **iOS Simulator** が前面に出て、アプリが起動します。

### ステップ F — Xcode コンソールで起動ログを確認する

1. メニュー **View → Debug Area → Activate Console** でコンソールを開く。
2. **`[YoiYoi Launch]`** で始まる行が流れていれば、[`AppLaunchDiagnostics`](../YoiYoi/YoiYoi/App/AppLaunchDiagnostics.swift) が動いており、起動順の切り分けに使える。
3. 画面が真っ白なのに **`WindowGroup ルート onAppear` や `ContentView.onAppear` が出ている**場合は、ウィンドウは生きているが **子ビューのレイアウト**を疑う。

#### コンソールに `onAppear` が出ているのに真っ白だけのとき

次を順に試してください。

1. **本当に Debug か**  
   - もう一度「ステップ C」で **Run → Info → Build Configuration = Debug** を確認。
2. **シミュレーターのリセット**  
   - シミュレーターがアクティブなとき、メニューバー **Device → Erase All Content and Settings…**（端末の内容と設定を消去）を実行し、確認して消去。
3. **Simulator を一度終了**  
   - メニュー **Simulator → Quit Simulator**、または **⌘ + Q**。  
   - Xcode からもう一度 **⌘ + R** で起動。
4. それでもダメなら **ターミナル** で次を実行してから、Xcode で再度 Run（詳細は下の「6. それでも真っ白なとき」参照）。

### ステップ G — Xcode 下部のコンソールでもログを見る（おまけ）

1. Xcode 下部に **デバッグエリア**（ログが流れるパネル）がない場合、メニュー **View → Debug Area → Activate Console**（表示 → デバッグエリア → コンソールをアクティブにする）で表示できます。
2. そこに **`[YoiYoi Launch]`** と書かれた行が出ていれば、それも診断ログです。パネルと同じ内容が並ぶことが多いです。

---

## 1. DEBUG ビルドで起動する

**Debug** 構成で Run してください（Release では `print` は減りますが、`os_log` は残ります）。  
※ 上の「初心者向け」に、Scheme の開き方から書いています。

## 2. Xcode コンソールの起動ログを見る

**`[YoiYoi Launch]`** の行で、どこまで起動処理が進んだかを確認する。  
真っ白で **ログもほとんど出ない** 場合は次を疑う。

- **Release で Run** している（`print` が出ない）  
- **シミュレーター / CoreSimulator** の不調（Simulator 終了 → Erase → 再起動）  
- 実行しているのが **別スキーム・別ターゲット** など

## 3. ログの読み方（例）

| ログ | 意味 |
|------|------|
| `YoiYoiAppDelegate.didFinishLaunching（Firebase 前）` | `UIApplicationDelegate` が動いている |
| `YoiYoiApp.init 開始` / `ModelContainer 作成成功` | SwiftUI `App` が起動し SwiftData を開けている |
| `WindowGroup ルート onAppear` | `WindowGroup` のルートが表示された |
| `FirebaseBootstrap: … configure スキップ` | `GoogleService-Info.plist` がバンドルにない（Firebase はオフ） |
| `AppRootView.onAppear … Onboarding` / `ContentView` | どちらの画面に分岐したか |
| `OnboardingContainerView.onAppear step=0` | オンボ EULA から始まっている |

## 4. Xcode コンソールのログ

- **`[YoiYoi Launch]`** で始まる行は、このアプリの **起動診断**です。  
- **`I-COR000003`** … Firebase 未 `configure`（plist がバンドルにないと出やすい）。**白画面の直接原因とは限りません。**  
- **`load_eligibility_plist`** … **シミュレーター OS のノイズ**で、アプリとは無関係です。

## 5. macOS の Console.app（上級）

1. Console.app を開く  
2. 左でシミュレーター端末またはプロセスを選択  
3. 検索に **`YoiYoi`** または **`Launch`**（`subsystem` はバンドル ID）  

`Logger` の `category: Launch` でフィルタできます。

## 6. それでも真っ白なとき

1. **Device → Erase All Content and Settings**  
2. `killall Simulator` のあと Xcode から再度起動  
3. **Product → Clean Build Folder**  
4. Xcode 左の **Report navigator（⌘9）** で **Crash** がないか確認  

---

## Clean → Run でコンソールログを確認する（詳しい手順）

**DEBUG ビルド**で Xcode コンソールに **`[YoiYoi Launch]`** が出るかを確認する。

| 確認するもの | 意味 |
|--------------|------|
| **`WindowGroup ルート onAppear`** | `WindowGroup` が表示された |
| **`AppRootView.onAppear`** | ルート分岐まで描画された |
| **`ContentView.onAppear`** | メイン UI コンテナが表示された |

### 手順 1 — Clean Build Folder する

古いビルド成果物を消して、**今のソースから一からビルド**します。

1. Xcode のメニュー **Product**（プロダクト）をクリック  
2. **Hold Option (⌥)** しながら **Product** を開く  
3. **「Clean Build Folder…」**（ビルドフォルダをクリーン）が出るのでクリック  
   - ショートカット: **⇧⌘K**（Shift + Command + K）  
4. 確認ダイアログが出たら **Clean**（クリーン）で OK  

### 手順 2 — Debug で Run する

1. 前述の **「ステップ C」** で **Run → Build Configuration が Debug** であることを確認  
2. シミュレーター（例: iPhone 16 Pro）を選ぶ  
3. **⌘R**（Run）で起動  

### 手順 3 — シミュレーターとコンソールで何を見るか

起動後、**すぐ**次を確認します。

1. シミュレーターに **期待どおりの画面**（クリームやタブなど）が出るか  
2. コンソールに **`[YoiYoi Launch]`** が時系列で出ているか（どこで止まったか）

---

## まだ真っ白なら：`-YoiYoiMinimal` を付けて Run（詳しい手順）

これは **SwiftData も `AppRootView` も使わず**、**真っ赤な画面 + 白文字だけ**を出すモードです。  
**`UIWindow` + `UIHostingController` が描画できるか**を切り分けます。

### 手順 A — Scheme を開く

1. Xcode 上部ツールバーで **Scheme**（左側の `YoiYoi` など）をクリック  
2. **「Edit Scheme…」**（スキームを編集…）を選ぶ  

### 手順 B — Run に起動引数を足す

1. 左の一覧で **Run** を選ぶ  
2. 上のタブで **Arguments**（引数）を開く  
3. **「Arguments Passed On Launch」**（起動時に渡す引数）の **+** ボタンを押す  
4. 新しい行に **次の文字列だけ** 入力する（スペースや引用符は不要）:  
   ```text
   -YoiYoiMinimal
   ```  
5. 左の **チェックボックスがオン**になっていることを確認（オフだと渡りません）  
6. **Close** で閉じる  

### 手順 C — もう一度 Clean → Run

1. 再度 **⇧⌘K**（Clean Build Folder）  
2. **⌘R**（Run）  

### 結果の読み方

| 見え方 | 解釈の目安 |
|--------|------------|
| **真っ赤な画面**に「YoiYoi MINIMAL (-YoiYoiMinimal)」のような白文字が見える | **UIKit ウィンドウとホスティングが生きている**。通常時の真っ白は **`AppRootView` / SwiftData / その子ビュー**側を調べる段階。 |
| **`-YoiYoiMinimal` でも真っ白**のまま | **別ターゲットを実行**、**シミュレーター異常**、**起動引数がオフ**など、もっと手前の問題を疑う。 |

### 手順 D — 引数を元に戻す

切り分けが終わったら、**Edit Scheme → Run → Arguments** で **`-YoiYoiMinimal` の行を削除**するか **チェックを外す**。そのままだと常に MINIMAL 画面になります。

---

関連: [FIREBASE_AND_SIMULATOR_LOGS.md](FIREBASE_AND_SIMULATOR_LOGS.md)

---

## `WindowGroup` の onAppear が出ないとき

`YoiYoiAppDelegate.didFinishLaunching` は出るが **`WindowGroup ルート onAppear` が出ない**場合は、**別ターゲットを実行**、**古いビルド**、**シミュレーター異常**を疑う。`INFOPLIST_KEY_UIApplicationSceneManifest_Generation` が **YES** であること（Xcode がシーン用マニフェストを生成）も確認する。
