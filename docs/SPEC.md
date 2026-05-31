# YoiYoi 仕様書 v2.0 — Lean MVP 実装合意候補
> 最終更新: 2026.06.01
>
> ステータス: Lean MVP の旧機能整理、日英対応、クイック記録、飲み会モード、水分通知、ローカルコーチを実装済み。公開初期の利用傾向確認は App Store Connect の標準指標のみを使う。

## 概要

| 項目 | 内容 |
|------|------|
| アプリ名 | YoiYoi |
| コンセプト | 飲んだ日も飲まなかった日も、正直に記録して自分のペースと向き合うパーソナル飲酒トラッカー |
| ターゲット | 初期ASO/デザイン上の主ターゲットは20〜40代。実利用対象は20歳以上の成人全般 |
| プラットフォーム | iOS 18+ (iPhone)。AI 生成は iOS 26+ かつ Apple Intelligence 利用可能時に提供 |
| Apple Watch | iPhone の通知がシステム設定に応じて Watch へ転送される。Watch アプリは MVP 対象外 |
| 推奨端末 | Apple Intelligence 対応端末（AI 生成用）。非対応端末でもテンプレートコーチで全機能を利用可能 |
| 言語 | 日本語・英語（MVP）。将来は追加言語へ拡張可能な設計を維持 |
| 収益 | 実用機能は無料。広告なし。買い切りを主軸に、口調・キャラ・表情・テーマなど楽しさを解禁 |
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
- 飲酒記録は端末内に保存され、アカウントやクラウド共有なしで使える安心感を初回体験とストア表示で伝える。
- AI は「ユーザーの記録とペースに寄り添う相棒」であることを最上位のガードレールとする。飲酒を勧めず、医療・健康上の断定をせず、罪悪感・人格否定・羞恥を与えない。
- AI は今日の一言だけに限定せず、昨日の飲み過ぎ、今週のペース、休肝日提案、酒種ごとの傾向を踏まえた提案を行う。
- AI は開始前、記録直後、短時間の連続記録、飲み会モード中、時間帯・曜日の傾向、連続記録の継続に応じて、場面に合う短いコメントを出す。
- 50〜70代でも読める文字サイズ、タップしやすい操作面積、Dynamic Type 対応を維持する。
- データドリブンな改善は App Store Connect の標準指標、レビュー、TestFlight フィードバック、手元のQAで行う。

### プライバシーと分析方針

- アカウント作成、Firebase、独自サーバー、分析 SDK、広告 SDK、クラウド同期を含めない。
- 飲酒記録、プロフィール、セッション履歴、お気に入りドリンク設定は `SwiftData` に端末内保存する。
- 通知は `UNUserNotificationCenter` のローカル通知だけを使用する。
- Foundation Models 利用時も、入力する集計値は端末内で処理される Apple のオンデバイスモデル向けに限定する。
- Apple Intelligence のモデル取得や利用可否は OS が管理するため、アプリは利用不可状態を正常系として扱い、常にテンプレートへフォールバックする。
- 公開初期のデータ確認は App Store Connect の標準指標（インストール、クラッシュ、セッション、継続など）だけを使う。
- アプリ独自の利用イベント記録、外部分析SDK、自前サーバーへの利用イベント送信は実装しない。

### ❌ 持たないもの（意図的な不採用）

| 不採用機能 | 理由 |
|-----------|------|
| SNS / フィード / リアクション | ソーシャル全面廃止。サーバー運用コスト・UGC審査リスクがゼロに |
| Firebase（Auth / Firestore） | 認証・個人データ同期は不要 |
| アプリ独自の利用イベント記録 / 外部分析SDK / 自前分析サーバー | 公開初期は App Store Connect の標準指標だけを見る |
| 広告 / AdMob | プライバシー訴求、アルコール関連広告、健康データ文脈との相性が悪いため採用しない |
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
- `Core/Legal/AppLegalLinks.swift` と `docs/legal/privacy.html` は、飲酒記録の端末内保存方針に文面を更新した上で維持する。
- App Store のプライバシー回答では、現行版は端末外へユーザーデータを送信しないため「開発者または第三者がアクセスできる収集データなし」を前提に回答する。
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

### CoachPersonality (AI相棒モード)
```swift
enum CoachPersonality: String, CaseIterable, Codable, Identifiable {
    case friendly  = "friendly"   // 相棒: 標準。友達風で自然に寄り添う
    case gentle    = "gentle"     // やさしい見守り: 罪悪感を与えない
    case analyst   = "analyst"    // アナリスト: データを落ち着いて読み解く
    case dataBuddy = "data_buddy" // データさん: 数字をやわらかく翻訳する
    case gyaru     = "gyaru"      // ギャル: 明るく楽しいが飲酒は勧めない
    case tsundere  = "tsundere"   // ツンデレ: 遊び心。依存的・過度な親密さは禁止
    case strict    = "strict"     // 鬼コーチ: 厳しいが人格否定しない
    case sMode     = "s_mode"     // ドS風: 羞恥・罵倒なしの強め口調
    case sweetheart = "sweetheart" // 恋人風: 甘やかし寄り。過度な依存表現は禁止
    case sarcastic = "sarcastic"  // 少し辛口: 軽い皮肉。攻撃的にしない

    var id: String { rawValue }
    var displayName: String { ... }
    var safetyInstruction: String { ... }  // LLM の System Prompt に組み込むガードレール + 文体
}
```

**AI相棒の発話ルール**:
- 常に「ユーザーの記録とペースに寄り添う相棒」として振る舞う。
- 「安全」「飲んでいい」「まだ飲める」「健康上問題ない」など、医療・安全・許容量の断定をしない。
- 昨日の純アルコール量が日次目安を超えていて、今日の記録がまだない場合は「今日は休肝日にする？」という提案を優先する。
- 今週の純アルコール量が週次目安に近い場合は「今日は控えめにする」「先に量を決める」提案を行う。
- 過去記録から酒種別の平均純アルコール量を見て、特定の酒種で多くなりやすい場合は「その酒種は量を先に決めよう」と提案する。
- 開始前は「今日は先にここまでを決める」提案を行う。よく飲む種類・杯数・容量がある場合は、そのユーザーの記録に合わせて「ビール2杯まで」「ワイン100ml単位」など具体化する。
- 記録直後は、今日の合計gと目安までの残りを返し、必要に応じて水分補給や一呼吸を提案する。
- 短時間で複数回記録されている場合は、ペース検知として少し間を空ける提案を行う。
- 飲み会モード中は、開始からの経過時間に応じて水分補給や区切りの提案を行う。
- 連続して記録できている場合は、完璧さではなく継続そのものを肯定する。
- 同じ曜日や遅い時間帯に多くなりやすい傾向がある場合は、先に量を決める・早めに区切る提案を行う。
- ビール・ワイン・日本酒などの傾向は、ユーザーの保存済み記録だけから算出する。
- 生成AIが利用できない端末では、同じガードレールに沿ったローカルテンプレートで発話する。

**無料コアとして常に提供するAI支援**:
- 休肝日提案。
- 控えめにする提案。
- 記録直後の文脈コメント。
- 昨日/今週の基本振り返り。

**解禁・課金対象にできる表現要素**:
- 口調の種類。
- キャラクター、表情、テーマ。
- より豊かな言い回し。
- キャラごとの掛け合い。
- 限定キャラ、限定テーマ、セリフ量、演出。
- 将来的なウィジェット。

**採用しないキャラ表現**:
- `ドクター` という名称や医療専門家に見える表現は使わない。データ寄りの役割は `アナリスト` / `データさん` として扱う。

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
│  Home    Calendar   （＋）  Settings│
│  ホーム  カレンダー          設定   │
│                                    │
└────────────────────────────────────┘
```
- 3タブ + 中央 FAB
- タブバー・FAB のデザインは DESIGN.md v3.0 踏襲

### オンボーディング（3画面に簡素化）

| # | ステップ | 内容 |
|---|---------|------|
| 1 | 言語選択 | 日本語 / English から選択。将来追加言語にも対応可能な一覧表示 |
| 2 | 性別＋目安 | 性別選択 → 参考値を提示し、ユーザーが調整可能 |
| 3 | コーチ性格 | 複数の相棒モードから選択。サンプルメッセージでプレビュー |

- ページインジケーター: coralRed の控えめなカプセル **3つ**
- 全画面背景は低彩度の `pureWhite → cream → mintLight`。言語選択を邪魔しない
- 言語選択画面では言語選択だけに集中する。端末内保存の訴求は初回導線内の説明、App Store、設定のデータとプライバシー領域で明確に表示する
- **削除**: EULA画面、ニックネーム選択画面

### ホーム画面

テーマ色: 摂取量に応じて変化する。大人向けの低彩度・高コントラスト設計

```
┌──────────────────────────────────────┐
│                                      │
│  ┌────────────────────────────────┐  │  ← ウェーブヒーロー（既存踏襲）
│  │  本日のアルコール摂取           │  │     28pt Bold, white
│  │      ┌──────────────┐          │  │     AlcoholMeterView（既存踏襲）
│  │      │    12g       │          │  │     160×160, 48pt Heavy, white
│  │      │   /40g       │          │  │
│  │      └──────────────┘          │  │
│  │  目安まであと 28g                │  │
│  └─～～～～～～～～～～～～～～～─┘  │
│                                      │
│  ┌─── 相棒コメント ───────────────┐  │  ← コーチカード
│  │  "記録できています。              │  │     コンテンツカード（白, radius 28）
│  │     水分も忘れずにね。"          │  │     タイプライターアニメーション
│  │          友達風 ⟳              │  │     性格バッジ + リロードボタン
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── すぐ記録 ──────────────────┐  │  ← ★ 新規: ワンタップ記録
│  │  よく飲む [ビール] [サワー]     │  │     お気に入り: 最大6件
│  │  最近     [ワイン] [ビール]     │  │     異なる直近記録: 最大5件
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 今週のまとめ ──────────────┐  │  ← 既存踏襲
│  │  [休肝日 3日] [連続 5日]       │  │     StatCard × 3
│  │  [週合計 84g]                  │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 今日のドリンク ────────────┐  │  ← 既存踏襲
│  │  [ビール 14g] [ワイン …]       │  │     横スクロール Pill
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 飲み会モード ────────────┐  │  ← セッション開始
│  │  飲み会を始める               │  │     グラデーションアクセントカード
│  │  タップして飲み会モードへ      │  │     successDeep → mintGreen
│  └────────────────────────────────┘  │
│                                      │
├──────────────────────────────────────┤
│  Home  Calendar  (＋)  Settings     │
└──────────────────────────────────────┘
```

**ホームヒーローの状態色**:
- 40% 未満: `successDeep` → `mintGreen`
- 40% 以上 80% 未満: `navy` → `successDeep`
- 80% 以上 110% 未満: `amber80` → `warmCoral`
- 110% 以上 135% 未満: `warmCoral` → `coralRed`
- 135% 以上: `darkBg` → `coralDeep`
- 色は目安との差を示す補助表現であり、「安全量」や「追加で飲める量」とは表現しない。

**ホームのクイック記録**:
- 「よく飲む」は `QuickDrinkPreset` を最大6件、横スクロールで表示する。未設定時は「＋ よく飲むドリンクを登録」を表示する。
- 「最近」は直近の異なる記録を最大5件表示する。記録がない場合は行を表示しない。
- タップ直後に記録し、画面下部に「ビールを記録しました　取り消す」を5秒間表示する。
- 長押しまたは編集ボタンから、お気に入りの登録・変更・並び替えに進める。

### 飲み会モード（Active Session）— ★ 新規

テーマ色: `warmCoral` / `amber80`。高揚感は出すが、警告色に見せすぎない

`.fullScreenCover` で表示。

```
┌──────────────────────────────────────┐
│  ┌────────────────────────────────┐  │  ← ウェーブヒーロー
│  │  飲み会モード                  │  │     warmCoral → amber80
│  │      1:32:15                  │  │     経過時間: 48pt Heavy, charcoal
│  │  [3杯] [水 2回] [28g]         │  │     ミニバッジ × 3
│  └─～～～～～～～～～～～～～～～─┘  │
│                                      │
│  ┌─── 相棒コメント ───────────────┐  │  ← コーチカード
│  │  "ここで水を挟むと後半が楽。"  │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌ 水を飲んだ                    ┐  │  ← mintGreen グラデボタン
│  ┌ もう一杯記録する              ┐  │  ← coralRed PuffyButton
│  ┌ ラストオーダー確認            ┐  │  ← warmCoral ボーダーボタン
│  ┌ 飲み会を終了する              ┐  │  ← greyText テキストボタン
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
- 「ここで区切る」→ `preventedLastOrder = true` → 控えめな称賛演出 + コーチ称賛
- 「もう1杯記録する」→ DrinkLogSheet を表示
- カレンダーに SVG の達成バッジで記録

### カレンダー画面（既存踏襲 + 微拡張）

テーマ色: `successDeep` / `mintGreen` / `mintLight`

- レイアウト、グリッド、週間棒グラフは DESIGN.md v3.0 のカード、境界線、影に合わせる
- **追加**: ラストオーダーを我慢できた日に SVG の達成バッジ

### 飲酒記録シート（既存踏襲）

- ドリンクグリッド、度数ステッパー、PuffyButton すべて既存踏襲
- シート上部にも **お気に入り最大6件** と **最近使った記録最大5件** のクイック選択を表示する。
- シート内のクイック選択は値をフォームに反映し、「記録する」ボタンで確認保存できる。ホーム上のワンタップ保存とは挙動を分ける。
- 調整した組み合わせを「よく飲むに追加」できる。上限6件では既存プリセットの編集・置換を促す。
- **追加**: 飲み会モード中は `DrinkRecord.sessionID` を自動セット

### 設定画面（スリム化）

テーマ色: `darkBg` / `lavender`

```
┌──────────────────────────────────────┐
│  ┌────────────────────────────────┐  │  ← ウェーブヒーロー
│  │  設定                          │  │     darkBg → lavender
│  └─～～～～～～～～～～～～～～～─┘  │
│                                      │
│  ┌─── 相棒モード ──────────────┐  │
│  │  話し方         [友達風 ▼]    │  │
│  │  プレビュー: "水分も忘れずにね" │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 飲み会モード ────────────┐  │
│  │  水分補給通知   [30分ごと ▼] │  │
│  │  ラストオーダー確認 [── ●]   │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 目安設定 ───────────────┐  │
│  │  性別 / 1日の目標 / 1週間の目標 │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌─── 情報 ───────────────────┐  │
│  │  バージョン v2.0.0              │  │
│  │  プライバシーポリシー          > │  │
│  └────────────────────────────────┘  │
│                                      │
│  本アプリは医療アドバイスを          │  ← 免責1行（これだけで十分）
│  提供するものではありません           │
│                                      │
├──────────────────────────────────────┤
│  Home  Calendar  (＋)  Settings     │
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
回答は50文字以内、1文、日本語。絵文字は使わない。
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

| 状態 | 鬼コーチ | やさしい見守り |
|------|----------|----------|
| 目標内 | 今日はここまでいいペース。水も挟もう。 | いい感じです。無理なく整っています。 |
| 80%超 | ここで区切る準備。次は水で立て直そう。 | そろそろ少しゆっくりでもよさそうです。 |
| 超過 | 今日はここで止める。明日は軽めに整えよう。 | 少し多めでした。今日は休む選択も大事です。 |
| 休肝日 | 記録なし、いい調整日だ。このままいこう。 | 休む選択も、ちゃんと前進です。 |

`friendly` と `sarcastic` にも同一の安全制約でテンプレートを用意する。「毒舌」はユーザー本人への侮辱や飲酒の煽りにしない。

### 安全要件

- 純アルコール量と設定した目安の比較を表示するが、「飲める量」「安全な量」と表現しない。
- AI/テンプレートは診断、治療、服薬判断、依存症の判定を行わない。
- 超過時は責めず、水分補給・記録・休息などの低リスクな声かけに限定する。
- 設定画面に「本アプリは医療アドバイスを提供するものではありません」を常時表示する。

---

## ドリンク初期データ（既存踏襲）

| 種類 | アイコン | 容量 | 度数 | 純AL |
|------|----------|------|------|------|
| ビール | `icon_drink_beer` | 350ml | 5% | 14g |
| ワイン | `icon_drink_wine` | 125ml | 12% | 12g |
| 日本酒 | `icon_drink_sake` | 180ml | 15% | 21.6g |
| ウイスキー | `icon_drink_whisky` | 30ml | 40% | 9.6g |
| カクテル | `icon_drink_cocktail` | 200ml | 5% | 8g |
| サワー | `icon_drink_sour` | 350ml | 5% | 14g |

---

## 将来のマネタイズ

| 区分 | 方針 | 備考 |
|------|------|------|
| 無料コア | 実用機能と安全寄りAI支援は無料 | 記録、編集、休肝日提案、控えめ提案、記録直後コメント、昨日/今週の基本振り返り |
| 累積解禁 | 正直に記録した累積日数で口調・キャラ・テーマを解禁 | 連続記録は飾り。途切れても解禁は失われない |
| 買い切り | 解禁対象を一気に開放 | 限定キャラ、限定テーマ、表情、演出、セリフ量を含める |
| 広告 | 採用しない | プライバシー訴求、アルコール関連広告、健康データ文脈との相性が悪い |

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

- 飲酒記録は端末内に保存し、開発者または第三者へ送信しない設計とする
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
