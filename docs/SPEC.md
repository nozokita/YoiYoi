# YoiYoi 仕様書 v2.0 — Lean MVP 実装合意候補
> 最終更新: 2026.05.26
>
> ステータス: Lean MVP の旧機能整理、日英対応、クイック記録、飲み会モード、水分通知、ローカルコーチを実装済み。

## 概要

| 項目 | 内容 |
|------|------|
| アプリ名 | YoiYoi |
| コンセプト | 楽しく、無理しないペースでアルコール摂取量をコントロールするパーソナル飲酒トラッカー |
| ターゲット | 飲酒習慣を管理したい、つい飲みすぎてしまうユーザー |
| プラットフォーム | iOS 18+ (iPhone)。AI 生成は iOS 26+ かつ Apple Intelligence 利用可能時に提供 |
| Apple Watch | iPhone の通知がシステム設定に応じて Watch へ転送される。Watch アプリは MVP 対象外 |
| 推奨端末 | Apple Intelligence 対応端末（AI 生成用）。非対応端末でもテンプレートコーチで全機能を利用可能 |
| 言語 | 日本語・英語（MVP）。将来は追加言語へ拡張可能な設計を維持 |
| 収益 | v2.0 は広告なし。将来的に AdMob + 広告非表示サブスクを検討 |
| デザイン | [DESIGN.md](./DESIGN.md) v2.0 のデザイン方針を踏襲 |

## コア4本柱

このアプリが提供する価値はこの4つに集約される。これ以外の機能は持たない。

| # | 柱 | 内容 |
|---|-----|------|
| 1 | **飲酒トラッカー** | 飲んだお酒の種類・量・度数から純アルコール量(g)を自動計算し、設定した目安と比較 |
| 2 | **記録** | 日々の飲酒をSwiftDataに保存し、カレンダーで振り返れる |
| 3 | **通知** | 飲み会モード中の水分補給リマインド。iPhone で通知し、条件を満たせば Watch に転送 |
| 4 | **ローカルAI** | 利用可能な端末ではオンデバイス LLM、その他はローカルテンプレートでコーチング |

### プロダクト原則

- 飲酒そのものを否定せず、楽しい時間を保ちながら自分のペースを意識できる体験にする。
- 記録は負担にしない。飲んでいる場面でも数秒で残せるショートカットを中心にする。
- 目安はユーザーが自分で調整できる基準として扱い、安全量や追加で飲んでよい量とは表現しない。
- 記録内容は端末内に保存され、アカウントやクラウド共有なしで使える安心感を初回体験とストア表示で伝える。

### 完全オフラインの定義

- アカウント作成、Firebase、独自サーバー、分析 SDK、広告 SDK、クラウド同期を含めない。
- 飲酒記録、プロフィール、セッション履歴、お気に入りドリンク設定は `SwiftData` に端末内保存する。
- 通知は `UNUserNotificationCenter` のローカル通知だけを使用する。
- Foundation Models 利用時も、入力する集計値は端末内で処理される Apple のオンデバイスモデル向けに限定する。
- Apple Intelligence のモデル取得や利用可否は OS が管理するため、アプリは利用不可状態を正常系として扱い、常にテンプレートへフォールバックする。

### ❌ 持たないもの（意図的な不採用）

| 不採用機能 | 理由 |
|-----------|------|
| SNS / フィード / リアクション | ソーシャル全面廃止。サーバー運用コスト・UGC審査リスクがゼロに |
| Firebase（Auth / Firestore） | サーバー不要。完全オフライン完結 |
| EULA 同意フロー | SNSがないため初回同意画面は設けない。免責とプライバシーポリシー導線は設定に残す |
| ニックネームシステム（国旗+絵文字+形容詞+名詞） | ソーシャルでの匿名ID用だった。パーソナルアプリには不要 |
| 通報・ブロック | ソーシャルなし → 不要 |
| データエクスポート（CSV） | v2.0 MVPでは省略。将来的に設定画面に追加可能 |
| ダークモード | v2.0 MVPでは省略 |

### 言語とローカライゼーション方針

- MVP は日本語 (`ja`) と英語 (`en`) を提供する。初回オンボーディングで選択でき、設定画面でいつでも切り替え可能にする。
- `SupportedLanguage` と言語別の UI 文言管理は維持する。新機能のテキストも JA/EN の双方を実装対象とする。
- 将来の追加言語では、`SupportedLanguage` へのケース追加、ローカライズ文字列、必要なフォント調整で広げられる構成を維持する。
- 飲酒記録やお気に入りの保存形式は言語に依存しない識別子を使い、表示文言だけを選択言語で切り替える。

---

## v1.0 → v2.0 削除対象ファイル一覧

| ファイル / ディレクトリ | 理由 |
|----------------------|------|
| `App/FirebaseBootstrap.swift` | Firebase 撤去 |
| `Core/Services/AuthService.swift` | Firebase Auth |
| `Core/Services/FirestoreService.swift` | Firestore |
| `Core/Services/FeedGenerator.swift` | フィード投稿生成 |
| `Core/Services/FeedFirestoreSync.swift` | Firestore 同期 |
| `Core/Services/FeedPost+Firestore.swift` | Firestore 変換 |
| `Core/Services/DataExportService.swift` | MVP では省略 |
| `Core/Models/FeedPost.swift` | フィードモデル |
| `Core/Models/NicknamePresets.swift` | ニックネーム用 |
| `Features/Feed/` 配下すべて | フィード UI |
| `Features/Onboarding/Views/EULAView.swift` | EULA 画面 |
| `Features/Onboarding/Views/NicknameSelectView.swift` | ニックネーム選択 |
| `Features/Settings/Views/SettingsNicknameEditView.swift` | ニックネーム編集 |
| `Features/Settings/Views/SettingsDataExportView.swift` | CSV エクスポート |
| `UI/Components/FlagPicker.swift` | 国旗ピッカー |
| `Resources/EULA/` 配下すべて | EULA テキスト |
| `Resources/NicknameData/` 配下すべて | ニックネーム JSON |
| `firestore.rules` | セキュリティルール |
| `FirestoreRulesTests/` 配下すべて | ルールテスト |
| Firebase SPM パッケージ依存 | Package.resolved から除去 |

### 維持する起動処理

- `App/YoiYoiAppDelegate.swift` はローカル通知をフォアグラウンド表示する `UNUserNotificationCenterDelegate` として維持する。削除するのはクラウド初期化処理のみとする。

### 維持する法務導線

- App Store Connect ではプライバシーポリシー URL が必須で、アプリ内にも容易に到達できるリンクを置く。
- `Core/Legal/AppLegalLinks.swift` と `docs/legal/privacy.html` は、完全オフライン方針に文面を更新した上で維持する。
- 初回の EULA 同意 UI と、旧ソーシャル機能を前提にした利用規約本文は撤去する。

---

## データモデル

### AlcoholByVolume（既存踏襲）
```swift
struct AlcoholByVolume: Codable, Hashable, Sendable {
    let fraction: Double                          // 0.0〜1.0
    var percentage: Double { fraction * 100 }
    static func fromPercentage(_ percent: Double) -> AlcoholByVolume { ... }
    static func fromFraction(_ value: Double) -> AlcoholByVolume { ... }
}
```

### DrinkRecord (SwiftData — 既存踏襲 + 微拡張)
```swift
@Model
final class DrinkRecord {
    @Attribute(.unique) var id: UUID = UUID()
    var drinkType: String
    var volumeML: Double
    var abvFraction: Double
    var pureAlcoholGrams: Double
    var numberOfDrinks: Int
    var loggedAt: Date
    var weekNumber: Int
    var yearNumber: Int
    var sessionID: UUID?       // ★ 追加: 飲み会セッションとの紐付け（nil = セッション外）
}
```

### UserProfile (SwiftData — 大幅スリム化)
```swift
@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID = UUID()
    var gender: String = "male"
    var weeklyGoalGrams: Double = 280
    var dailyGoalGrams: Double = 40
    var language: String = "ja"                  // SupportedLanguage.rawValue
    var onboardingCompleted: Bool = false
    var createdAt: Date = Date()

    // AIコーチ設定
    var aiCoachPersonality: String = "friendly"   // CoachPersonality.rawValue
    var hydrationIntervalMinutes: Int = 30        // 水分補給通知の間隔（分）
    var lastOrderReminderEnabled: Bool = true     // ラストオーダーリマインド
}
```

> **削除フィールド**: `firebaseUID`, `nicknameFlag`, `nicknameEmoji`, `nicknameAdjective`, `nicknameNoun`, `eulaAccepted`, `eulaAcceptedAt`, `blockedUIDsData`。`language` は JA/EN 設定保持のため維持する。

### CoachPersonality (新規)
```swift
enum CoachPersonality: String, CaseIterable, Codable, Identifiable {
    case strict    = "strict"     // 🔥 スパルタ
    case gentle    = "gentle"     // 🌸 やさしめ
    case friendly  = "friendly"   // 😎 フレンドリー
    case sarcastic = "sarcastic"  // 😏 毒舌

    var id: String { rawValue }
    var displayName: String { ... }
    var personalityInstruction: String { ... }  // LLM の System Prompt に組み込む性格文
}
```

### DrinkingSession (SwiftData — 新規)
```swift
@Model
final class DrinkingSession {
    @Attribute(.unique) var id: UUID = UUID()
    var startTime: Date
    var endTime: Date?                    // nil = 進行中
    var hydrationCount: Int = 0           // 水を飲んだ回数
    var preventedLastOrder: Bool = false   // 余計な1杯を我慢できたか
    var isActive: Bool { endTime == nil }
}
```

### QuickDrinkPreset (SwiftData — 新規)
```swift
@Model
final class QuickDrinkPreset {
    @Attribute(.unique) var id: UUID = UUID()
    var displayName: String
    var drinkType: String
    var volumeML: Double
    var abvFraction: Double
    var numberOfDrinks: Int
    var sortOrder: Int
    var createdAt: Date = Date()
}
```

**クイック記録ルール**:
- **お気に入り**: ユーザーがよく飲む組み合わせを最大6件まで保存し、並べ替え・編集・削除できる。
- **最近使った記録**: `DrinkRecord` の最新履歴から、種類・容量・度数・杯数が同一のものを重複排除して直近5件を表示する。別モデルには保存しない。
- お気に入りまたは最近使った記録をタップすると、その内容で `DrinkRecord` を即時保存する。
- 誤タップ対策として、ワンタップ保存後に5秒間の「取り消す」アクションを表示する。
- 飲み会モード中のクイック記録にも、現在の `sessionID` を自動設定する。

### データ移行方針

- 既存の `DrinkRecord` は保持し、`sessionID` は移行時に `nil` として扱う。
- 既存の `UserProfile` は目標値・性別・オンボーディング完了状態を引き継ぎ、廃止フィールドは読み出さない。
- 新しい AI/通知設定は既定値（`friendly`、30分、ラストオーダー ON）で補完する。
- `QuickDrinkPreset` は新規追加とし、既存ユーザーはお気に入り未設定で開始する。最近使った記録は既存 `DrinkRecord` から自動表示できる。
- 開発中の破損したシミュレーターストアに対するリセット手順は維持するが、リリース済みユーザーデータの消去を移行手段にしない。

---

## プロジェクト構造（v2.0）

```
YoiYoi/
├── App/
│   ├── YoiYoiApp.swift
│   ├── AppState.swift
│   ├── AppRootView.swift
│   ├── YoiYoiAppDelegate.swift        # フォアグラウンド通知表示
│   └── ContentView.swift              # 3タブ + FAB
├── Features/
│   ├── Onboarding/                    # 3画面に簡素化
│   │   ├── Views/
│   │   │   ├── OnboardingContainerView.swift
│   │   │   ├── LanguageSelectView.swift
│   │   │   ├── GenderGoalView.swift
│   │   │   └── CoachPersonalitySelectView.swift   # ★ 新規
│   │   └── ViewModels/
│   │       └── OnboardingViewModel.swift
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift
│   │   │   ├── WaveHeroView.swift
│   │   │   ├── AlcoholMeterView.swift
│   │   │   ├── AICoachBubbleView.swift            # ★ 新規
│   │   │   ├── QuickDrinkManagerView.swift        # ★ 新規
│   │   │   └── ActiveSessionView.swift            # ★ 新規
│   │   └── ViewModels/
│   │       └── HomeViewModel.swift
│   ├── DrinkLog/                      # 既存踏襲
│   │   ├── Views/ ...
│   │   └── ViewModels/ ...
│   ├── Calendar/                      # 既存踏襲
│   │   ├── Views/ ...
│   │   └── ViewModels/ ...
│   └── Settings/
│       └── Views/
│           ├── SettingsRootView.swift  # スリム化
│           ├── SettingsGoalsEditView.swift
│           ├── SettingsNotificationsView.swift
│           └── CoachSettingsView.swift # ★ 新規
├── Core/
│   ├── Models/
│   │   ├── DrinkRecord.swift
│   │   ├── DrinkType.swift
│   │   ├── AlcoholByVolume.swift
│   │   ├── SupportedLanguage.swift    # JA / EN、追加言語へ拡張
│   │   ├── UserProfile.swift          # スリム化
│   │   ├── DrinkingSession.swift      # ★ 新規
│   │   ├── QuickDrinkPreset.swift     # ★ 新規
│   │   └── CoachPersonality.swift     # ★ 新規
│   ├── Services/
│   │   ├── AlcoholCalculator.swift
│   │   ├── NotificationService.swift  # 拡張（水分補給通知を追加）
│   │   ├── LocalAICoachService.swift  # ★ 新規
│   │   └── SessionManager.swift       # ★ 新規
│   └── Extensions/
│       ├── Date+Ext.swift
│       ├── Color+Ext.swift
│       └── View+Ext.swift
├── UI/                                # 既存踏襲（FlagPicker のみ削除）
│   ├── Theme/ ...
│   ├── Components/ ...
│   └── Modifiers/ ...
├── Resources/
│   └── Assets.xcassets/
└── Tests/
    ├── AlcoholByVolumeTests.swift
    ├── AlcoholCalculatorTests.swift
    ├── DrinkRecordTests.swift
    ├── QuickDrinkPresetTests.swift     # ★ 新規
    ├── SessionManagerTests.swift      # ★ 新規
    └── HydrationNotificationTests.swift # ★ 新規
```

---

## 画面仕様（3タブ + 2モーダル + オンボーディング）

### タブ構成

```
┌────────────────────────────────────┐
│                                    │
│   🏠       📅       （＋）    ⚙️   │
│  ホーム  カレンダー          設定   │
│                                    │
└────────────────────────────────────┘
```
- 3タブ + 中央 FAB
- タブバー・FAB のデザインは DESIGN.md v2.0 踏襲

### オンボーディング（3画面に簡素化）

| # | ステップ | 内容 |
|---|---------|------|
| 1 | 言語選択 | 日本語 / English から選択。将来追加言語にも対応可能な一覧表示 |
| 2 | 性別＋目安 | 性別選択 → 参考値を提示し、ユーザーが調整可能 |
| 3 | コーチ性格 | 4つの性格から選択。サンプルメッセージでプレビュー |

- ページインジケーター: coralRed ドット **3つ**
- 全画面グラデーション背景（coralRed → coralLight → cream）— 既存パターン踏襲
- 言語選択画面に JA / EN で安心訴求を表示: **「記録はこのiPhoneの中だけに保存されます」** / **"Your records stay on this iPhone."**
- 補足表示: **「アカウント登録なし・クラウド送信なし」** / **"No account. No cloud upload."**
- **削除**: EULA画面、ニックネーム選択画面

### ホーム画面

テーマ色: `coralRed` / `coralLight`（既存踏襲）

```
┌──────────────────────────────────────┐
│                                      │
│  ┌────────────────────────────────┐  │  ← ウェーブヒーロー（既存踏襲）
│  │  おつかれさま！🍺               │  │     28pt Bold, white
│  │      ┌──────────────┐          │  │     AlcoholMeterView（既存踏襲）
│  │      │    12g       │          │  │     160×160, 48pt Heavy, white
│  │      │   /40g       │          │  │
│  │      └──────────────┘          │  │
│  │  目安まであと 28g                │  │
│  └─～～～～～～～～～～～～～～～─┘  │
│                                      │
│  ┌─── 🤖 AIコーチ ────────────────┐  │  ← ★ 新規: コーチ吹き出しカード
│  │  💬 "記録できてえらい！           │  │     コンテンツカード（白, radius 24）
│  │     水分も忘れずにね。"          │  │     タイプライターアニメーション
│  │          😎 フレンドリー ⟳     │  │     性格バッジ + リロードボタン
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── すぐ記録 ──────────────────┐  │  ← ★ 新規: ワンタップ記録
│  │  よく飲む [🍺 ビール] [🍹 サワー]│  │     お気に入り: 最大6件
│  │  最近     [🍷 1杯] [🍺 2杯]    │  │     異なる直近記録: 最大5件
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 今週のまとめ ──────────────┐  │  ← 既存踏襲
│  │  [🍵 休肝日 3日] [🔥 連続 5日] │  │     StatCard × 3
│  │  [📊 週合計 84g]               │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 今日のドリンク ────────────┐  │  ← 既存踏襲
│  │  [🍺 ビール 14g] [🍷 ワイン …] │  │     横スクロール Pill
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 🍻 飲み会モード ──────────┐  │  ← ★ 新規: セッション開始
│  │  🍻 飲み会を始める！           │  │     グラデーションアクセントカード
│  │  タップして飲み会モードへ  🍺  │  │     coralLight → coralRed
│  └────────────────────────────────┘  │
│                                      │
├──────────────────────────────────────┤
│  🏠    📅    (＋)    ⚙️              │
└──────────────────────────────────────┘
```

**ホームのクイック記録**:
- 「よく飲む」は `QuickDrinkPreset` を最大6件、横スクロールで表示する。未設定時は「＋ よく飲むドリンクを登録」を表示する。
- 「最近」は直近の異なる記録を最大5件表示する。記録がない場合は行を表示しない。
- タップ直後に記録し、画面下部に「ビールを記録しました　取り消す」を5秒間表示する。
- 長押しまたは編集ボタンから、お気に入りの登録・変更・並び替えに進める。

### 飲み会モード（Active Session）— ★ 新規

テーマ色: `sunnyYellow` / `yellowLight`（旧フィード画面のテーマを再利用）

`.fullScreenCover` で表示。

```
┌──────────────────────────────────────┐
│  ┌────────────────────────────────┐  │  ← ウェーブヒーロー
│  │  🍻 飲み会モード                │  │     sunnyYellow → yellowLight
│  │      ⏱ 1:32:15                │  │     経過時間: 48pt Heavy, charcoal
│  │  [🍺 3杯] [💧 2回] [📊 28g]   │  │     ミニバッジ × 3
│  └─～～～～～～～～～～～～～～～─┘  │
│                                      │
│  ┌─── 🤖 AIコーチ ────────────────┐  │  ← コーチ吹き出し
│  │  💬 "3杯目か〜。水飲もう！🥤"  │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌ 💧 水飲んだ！                  ┐  │  ← mintGreen グラデボタン
│  ┌ 🍺 もう一杯記録する            ┐  │  ← coralRed PuffyButton
│  ┌ 🔔 ラストオーダー！            ┐  │  ← warmCoral ボーダーボタン
│  ┌ 🏠 飲み会を終了する            ┐  │  ← greyText テキストボタン
│                                      │
└──────────────────────────────────────┘
```

**水分補給通知**:
- `UNUserNotificationCenter` でローカル通知をスケジュール
- セッション開始時に `hydrationIntervalMinutes` ごとに最大10件登録
- **Apple Watch**: ペアリング・通知設定・利用状況に応じ、iPhone 通知がシステムによって Watch に転送されうる。両端末への同時表示は保証しない
- セッション終了時に未発火の通知をキャンセル

**ラストオーダー**:
- タップで確認アラート。AIコーチが性格に応じたメッセージで問いかけ
- 「✋ ストップ！」→ `preventedLastOrder = true` → 🎉 confetti + コーチ称賛
- 「🍺 もう1杯…」→ DrinkLogSheet を表示
- カレンダーに 🏆 バッジで記録

### カレンダー画面（既存踏襲 + 微拡張）

テーマ色: `mintGreen` / `mintLight`（既存踏襲）

- レイアウト、グリッド、週間棒グラフすべて既存踏襲
- **追加**: ラストオーダーを我慢できた日に 🏆 バッジ

### 飲酒記録シート（既存踏襲）

- ドリンクグリッド、度数ステッパー、PuffyButton すべて既存踏襲
- シート上部にも **お気に入り最大6件** と **最近使った記録最大5件** のクイック選択を表示する。
- シート内のクイック選択は値をフォームに反映し、「記録する」ボタンで確認保存できる。ホーム上のワンタップ保存とは挙動を分ける。
- 調整した組み合わせを「よく飲むに追加」できる。上限6件では既存プリセットの編集・置換を促す。
- **追加**: 飲み会モード中は `DrinkRecord.sessionID` を自動セット

### 設定画面（スリム化）

テーマ色: `lavender` / `#E1BEE7`（既存踏襲）

```
┌──────────────────────────────────────┐
│  ┌────────────────────────────────┐  │  ← ウェーブヒーロー
│  │  ⚙️ 設定                       │  │     lavender グラデーション
│  └─～～～～～～～～～～～～～～～─┘  │
│                                      │
│  ┌─── 🤖 AIコーチ ──────────────┐  │
│  │  コーチの性格   [😎フレンドリー▼]│  │
│  │  プレビュー: "水分も忘れずにね" │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 🍻 飲み会モード ──────────┐  │
│  │  💧 水分補給通知   [30分ごと ▼] │  │
│  │  🔔 ラストオーダー通知 [── ●]  │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 🎯 目標設定 ──────────────┐  │
│  │  性別 / 1日の目標 / 1週間の目標 │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── ℹ️ 情報 ──────────────────┐  │
│  │  バージョン v2.0.0              │  │
│  │  プライバシーポリシー          > │  │
│  └────────────────────────────────┘  │
│                                      │
│  ⚠️ 本アプリは医療アドバイスを       │  ← 免責1行（これだけで十分）
│  提供するものではありません           │
│                                      │
├──────────────────────────────────────┤
│  🏠    📅    (＋)    ⚙️              │
└──────────────────────────────────────┘
```

> **削除**: ニックネーム編集、ブロックリスト、ダークモード、データエクスポート、利用規約リンク。**維持**: 言語切替、プライバシーポリシーリンク。

---

## オンデバイス LLM 実装要件

### 実装方針

| 優先度 | 実装 | 対象 | 備考 |
|-------|------|------|------|
| 1 | **Foundation Models** | iOS 26+ かつモデルが `.available` の場合 | `SystemLanguageModel.default.availability` を必ず確認してから生成 |
| 2 | **ルールベーステンプレート** | 全端末 / AI 利用不可時 | MVP 必須の常時利用可能経路 |

- MVP では MLX Swift やアプリ独自のモデルダウンロードは導入しない。サイズ、初回体験、端末負荷の不確実性を避ける。
- Foundation Models 部は `#if canImport(FoundationModels)` と `@available(iOS 26.0, *)` で囲い、iOS 18-25 でも同一アプリが動作する構成にする。
- 生成エラー、Apple Intelligence 無効、モデル未準備、非対応端末はエラー表示にせずテンプレートへ切り替える。

### プロンプト設計
```
[System]
あなたは「{personality}」という性格の飲酒コーチです。
{personalityInstruction}
回答は50文字以内、1文、日本語。絵文字は0〜2個まで。
医療アドバイスは絶対にしないでください。
追加の飲酒を勧めたり、摂取可能量を断定したりしないでください。

[Context]
今日: {todayGrams}g / 目標{dailyGoal}g ({percentage}%)
今週: {weeklyGrams}g / 目標{weeklyGoal}g
飲み会モード: {sessionStatus}

[Task]
短く語りかけてください。
```

### フォールバック（LLM 非対応端末用）

LLM が使えない場合はルールベーステンプレートで代替:

| 状態 | 🔥スパルタ | 🌸やさしめ |
|------|----------|----------|
| 目標内 | 油断するなよ💪 | いい感じだよ🌸 |
| 80%超 | あと{n}gだ。覚悟は？🔥 | そろそろ気をつけてね🍵 |
| 超過 | オーバーだ。明日取り返すぞ😤 | ちょっと超えちゃったね💕 |
| 休肝日 | {n}日連続。これが当たり前だ👊 | {n}日も休肝すごい！🌿 |

`friendly` と `sarcastic` にも同一の安全制約でテンプレートを用意する。「毒舌」はユーザー本人への侮辱や飲酒の煽りにしない。

### 安全要件

- 純アルコール量と設定した目安の比較を表示するが、「飲める量」「安全な量」と表現しない。
- AI/テンプレートは診断、治療、服薬判断、依存症の判定を行わない。
- 超過時は責めず、水分補給・記録・休息などの低リスクな声かけに限定する。
- 設定画面に「本アプリは医療アドバイスを提供するものではありません」を常時表示する。

---

## ドリンク初期データ（既存踏襲）

| 種類 | emoji | 容量 | 度数 | 純AL |
|------|-------|------|------|------|
| ビール | 🍺 | 350ml | 5% | 14g |
| ワイン | 🍷 | 125ml | 12% | 12g |
| 日本酒 | 🍶 | 180ml | 15% | 21.6g |
| ウイスキー | 🥃 | 30ml | 40% | 9.6g |
| カクテル | 🍸 | 200ml | 5% | 8g |
| サワー | 🍹 | 350ml | 5% | 14g |

---

## 将来のマネタイズ

| バージョン | 広告 | サブスク | 備考 |
|-----------|------|---------|------|
| v2.0 | なし | なし | UX最優先 |
| v2.x | AdMob Banner | — | FeatureFlag で制御 |
| v3.x | AdMob | 広告非表示プラン | 月額 ¥200-300 を想定 |

---

## テスト戦略

| ファイル | テスト対象 | ケース数 |
|---------|-----------|---------|
| `AlcoholByVolumeTests.swift` | 型変換、境界値 | 6（既存） |
| `DrinkRecordTests.swift` | 純AL計算 | 8（既存） |
| `AlcoholCalculatorTests.swift` | 日計・週計・ストリーク | 8（既存） |
| `QuickDrinkPresetTests.swift` | お気に入り上限、直近履歴の重複排除、クイック記録への値反映 | 6（新規） |
| `SessionManagerTests.swift` | セッション制御 | 6（新規） |
| `HydrationNotificationTests.swift` | 通知スケジューリング | 4（新規） |

## App Store 審査対策

- 完全オフラインでユーザーの飲酒記録を開発者または第三者へ送信しない設計とする
- SNSなし → ユーザー投稿のモデレーション機能は対象外
- HealthKit 未使用 → HealthKit の権限・データ取扱いは対象外。ただし飲酒を扱うため安全な表現と免責は維持する
- 免責: 設定画面に「本アプリは医療アドバイスを提供するものではありません」
- プライバシーポリシー: App Store Connect メタデータとアプリ内設定画面の両方から到達可能にする
- AI 表現: Foundation Models の acceptable use requirements と安全要件に従う

### App Store / 初回訴求

**主メッセージ案**:
> 楽しく飲みながら、無理しないペースを見つけよう。

**紹介文案**:
> YoiYoi は、純アルコール量の記録、水分補給リマインド、やさしい声かけで、飲み会のペース管理を支えるアプリです。よく飲むドリンクや最近の記録をワンタップで残せます。飲酒記録はあなたの端末内だけに保存され、アカウント登録やクラウド送信はありません。

**English description draft**:
> YoiYoi helps you enjoy drinking at your own comfortable pace with alcohol tracking, hydration reminders, and gentle coaching. Log favorite drinks or recent entries with one tap. Your drinking records stay only on your device, with no account or cloud upload required.

**スクリーンショット／オンボーディングで必ず見せる訴求**:
- 「記録は端末だけに保存」 / "Records stay on your device"
- 「よく飲むドリンクをワンタップ記録」 / "Log favorites in one tap"
- 「設定した目安まであと28g」 / "28g until your set guide"
- 「飲み会中は水分補給をリマインド」 / "Hydration reminders while you drink"

---

## 方針確認と実装反映

| # | 方針 | 実装への影響 |
|---|----------|--------------|
| 1 | Deployment target は **iOS 18.0** のまま、Foundation Models は **iOS 26+ の任意強化**として実装する | iOS 18-25 / AI 無効端末はテンプレートで動作 |
| 2 | Firebase、フィード、匿名プロフィール、EULA 同意画面は完全撤去する | 依存パッケージ・Firestore rules・旧 UI/テストを削除 |
| 3 | プライバシーポリシーリンクは設定画面と Web 文書に残す | App Store 提出要件に対応 |
| 4 | 既存ローカル飲酒記録と目標設定は保持する移行を行う | SwiftData モデル追加/縮小時にデータ維持を優先 |
| 5 | コンセプトは **「楽しく、無理しないペースでアルコール摂取量をコントロールする」** とする | UI 文言とストア訴求をこの価値に統一 |
| 6 | 「あと何g飲める」ではなく **「設定した目安まであと28g」** を採用する | 健康安全上、飲酒推奨に見える表現を避ける |
| 7 | MVP は **日本語・英語** を維持し、将来の言語追加が可能な構造にする | `SupportedLanguage`、言語選択、設定の言語切替を維持 |
| 8 | お気に入りは最大6件、最近使った異なる記録は最大5件を表示する | ホーム／記録シート・モデル・テストを追加 |
| 9 | 初回画面と App Store 紹介で **「記録は端末だけに保存」** を JA/EN で明確に訴求する | オンボーディングと配布文面を更新 |
| 10 | MVP の AI は Foundation Models + テンプレートに限定し、MLX は対象外とする | アプリサイズ増加と別モデル管理を回避 |

### 参照した Apple 公式情報（2026.05.26 確認）

- [Foundation Models](https://developer.apple.com/documentation/foundationmodels/)
- [Generating content and performing tasks with Foundation Models](https://developer.apple.com/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models)
- [Notifications on watchOS](https://developer.apple.com/documentation/watchOS-Apps/notifications)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App privacy details on the App Store](https://developer.apple.com/app-store/app-privacy-details/)
