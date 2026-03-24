# YoiYoi 仕様書 v5.0 — MVP 実装版
> 最終更新: 2026.03.21

## 概要

| 項目 | 内容 |
|------|------|
| アプリ名 | YoiYoi |
| コンセプト | ゆるふわ飲酒トラッカー × 世界のみんなで励まし合い |
| ターゲット | 20-40代の飲酒習慣を管理したいユーザー |
| プラットフォーム | iOS 17+ (iPhone) |
| 言語（MVP） | 日本語（デフォルト）・英語 |
| 言語（将来） | 韓国語・その他（多言語追加を容易にする設計） |
| 収益 | v1.0 は広告なし。MAU 300-500 到達後に AdMob Adaptive Banner 導入 |
| デザイン | [DESIGN.md](./DESIGN.md) 参照 |

## 多言語設計方針

MVP では JA / EN の2言語のみ対応するが、以下の設計で言語追加を容易にする。

- **全 UI 文字列**: String Catalogs (.xcstrings) で管理。新言語追加は .xcstrings にロケール追加のみ。
- **ニックネームデータ**: `adjectives_{lang}.json` / `nouns_{lang}.json` 形式。新言語は JSON ファイル追加のみ。
- **フィードテンプレート**: Localizable.xcstrings 内のキーで管理。新言語はキーの翻訳追加のみ。
- **フォント定義**: `AppFonts.swift` で言語ごとのフォントファミリーを定義。新言語はケース追加のみ。
- **言語選択UI**: `LanguageSelectView` はデータ駆動で、`SupportedLanguage` enum にケース追加すれば自動表示。

```swift
// 言語追加の手順（例: 韓国語追加）
// 1. SupportedLanguage enum に .ko を追加
// 2. Localizable.xcstrings に ko ロケール追加・翻訳
// 3. adjectives_ko.json, nouns_ko.json を Resources/NicknameData/ に追加
// 4. AppFonts.swift に ko 用フォント（Apple SD Gothic Neo）を追加
// コード変更は enum の1行 + フォント定義の数行のみ
```

## プロジェクト構造

```
YoiYoi/
├── App/
│   ├── YoiYoiApp.swift
│   ├── YoiYoiAppDelegate.swift
│   ├── AppState.swift
│   ├── ContentView.swift          # TabView ルート
│   ├── FeatureFlags.swift
│   └── FirebaseBootstrap.swift    # FirebaseCore 条件付き configure（plist なしでもビルド可）
├── Features/
│   ├── Onboarding/
│   │   ├── Views/
│   │   │   ├── OnboardingContainerView.swift
│   │   │   ├── EULAView.swift
│   │   │   ├── LanguageSelectView.swift
│   │   │   ├── GenderGoalView.swift
│   │   │   └── NicknameSelectView.swift
│   │   └── ViewModels/
│   │       └── OnboardingViewModel.swift
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift
│   │   │   ├── WaveHeroView.swift         # ★ 共通ウェーブヒーロー
│   │   │   ├── AlcoholMeterView.swift
│   │   │   └── StatCardView.swift
│   │   └── ViewModels/
│   │       └── HomeViewModel.swift
│   ├── DrinkLog/
│   │   ├── Views/
│   │   │   ├── DrinkLogSheet.swift
│   │   │   ├── DrinkGridView.swift
│   │   │   └── QuantitySliderView.swift
│   │   └── ViewModels/
│   │       └── DrinkLogViewModel.swift
│   ├── Calendar/
│   │   ├── Views/
│   │   │   ├── CalendarView.swift
│   │   │   └── DayCellView.swift
│   │   └── ViewModels/
│   │       └── CalendarViewModel.swift
│   ├── Feed/
│   │   ├── Views/
│   │   │   ├── FeedView.swift
│   │   │   ├── FeedCardView.swift
│   │   │   └── ReactionBarView.swift
│   │   └── ViewModels/
│   │       └── FeedViewModel.swift
│   └── Settings/
│       ├── Views/
│       │   ├── SettingsView.swift
│       │   └── NicknameEditView.swift
│       └── ViewModels/
│           └── SettingsViewModel.swift
├── Core/
│   ├── Models/
│   │   ├── DrinkRecord.swift
│   │   ├── DrinkType.swift
│   │   ├── AlcoholByVolume.swift
│   │   ├── UserProfile.swift
│   │   ├── FeedPost.swift
│   │   ├── SupportedLanguage.swift
│   │   └── NicknamePresets.swift
│   ├── Services/
│   │   ├── AlcoholCalculator.swift
│   │   ├── FirestoreService.swift
│   │   ├── AuthService.swift
│   │   └── FeedGenerator.swift
│   └── Extensions/
│       ├── Date+Ext.swift
│       ├── Color+Ext.swift
│       └── View+Ext.swift
├── UI/
│   ├── Theme/
│   │   ├── AppColors.swift
│   │   ├── AppFonts.swift
│   │   ├── AppGradients.swift
│   │   └── AppSpacing.swift
│   ├── Components/
│   │   ├── PuffyButton.swift
│   │   ├── ContentCard.swift            # ★ 白背景カード（旧FrostCard統合）
│   │   ├── GradientAccentCard.swift     # ★ 横長グラデーションカード
│   │   ├── StatCard.swift
│   │   ├── PillTag.swift
│   │   ├── FlagPicker.swift
│   │   └── WaveShape.swift              # ★ ウェーブ CustomShape
│   └── Modifiers/
│       ├── ThemedShadowModifier.swift   # ★ テーマ色シャドウ（統合）
│       └── BounceModifier.swift
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Colors/
│   │   └── Images/
│   ├── Localizable.xcstrings
│   ├── EULA/
│   │   ├── eula_ja.md
│   │   └── eula_en.md
│   └── NicknameData/
│       ├── flags.json
│       ├── emojis.json
│       ├── adjectives_ja.json
│       ├── adjectives_en.json
│       ├── nouns_ja.json
│       └── nouns_en.json
└── Tests/
    ├── AlcoholByVolumeTests.swift
    ├── AlcoholCalculatorTests.swift
    ├── DrinkRecordTests.swift
    ├── FeedGeneratorTests.swift
    └── FirestoreRulesTests/
        ├── package.json
        └── firestore-rules.test.js
```

## データモデル

### AlcoholByVolume（型安全な度数）
```swift
/// UI では 0-100 のパーセント表示、内部計算では 0.0-1.0 の小数を使う。
/// この型で変換ミスによる100倍ズレを防止する。
struct AlcoholByVolume: Codable, Hashable, Sendable {
    /// 内部値は常に小数（0.0〜1.0）。例: 5% → 0.05
    let fraction: Double

    /// パーセント表示用（UIスライダー/ステッパー向け）。例: 0.05 → 5.0
    var percentage: Double { fraction * 100 }

    /// パーセント値から生成（UI入力）。例: 5.0 → fraction 0.05
    static func fromPercentage(_ percent: Double) -> AlcoholByVolume {
        precondition(percent >= 0 && percent <= 100, "ABV must be 0-100%")
        return AlcoholByVolume(fraction: percent / 100)
    }

    /// 小数値から生成（コード内部/JSONデータ）。例: 0.05
    static func fromFraction(_ value: Double) -> AlcoholByVolume {
        precondition(value >= 0 && value <= 1.0, "ABV fraction must be 0.0-1.0")
        return AlcoholByVolume(fraction: value)
    }
}
```

### DrinkRecord (SwiftData)
```swift
@Model
final class DrinkRecord {
    @Attribute(.unique) var id: UUID = UUID()
    var drinkType: String        // "beer","wine","sake","whisky","cocktail","sour"
    var volumeML: Double
    var abvFraction: Double      // 0.0-1.0（AlcoholByVolume.fraction から取得）
    var pureAlcoholGrams: Double  // volumeML * abvFraction * 0.8 * numberOfDrinks
    var numberOfDrinks: Int
    var loggedAt: Date
    var weekNumber: Int
    var yearNumber: Int

    init(drinkType: String, volumeML: Double, abv: AlcoholByVolume, numberOfDrinks: Int) {
        self.drinkType = drinkType
        self.volumeML = volumeML
        self.abvFraction = abv.fraction
        self.numberOfDrinks = numberOfDrinks
        self.pureAlcoholGrams = volumeML * abv.fraction * 0.8 * Double(numberOfDrinks)
        let now = Date()
        self.loggedAt = now
        let cal = Calendar.current
        self.weekNumber = cal.component(.weekOfYear, from: now)
        self.yearNumber = cal.component(.yearForWeekOfYear, from: now)
    }
}
```

### SupportedLanguage（言語拡張用 enum）
```swift
enum SupportedLanguage: String, CaseIterable, Codable, Identifiable, Sendable {
    case ja = "ja"
    case en = "en"
    // 将来追加: case ko = "ko"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ja: return "日本語"
        case .en: return "English"
        }
    }

    var flag: String {
        switch self {
        case .ja: return "🇯🇵"
        case .en: return "🇺🇸"
        }
    }

    var fontFamily: String {
        switch self {
        case .ja: return "Hiragino Sans"
        case .en: return ".SFProRounded"
        }
    }
}
```

### UserProfile (SwiftData)
```swift
@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID = UUID()
    var firebaseUID: String = ""
    var nicknameFlag: String = "🇯🇵"
    var nicknameEmoji: String = "🌙"
    var nicknameAdjective: String = "ほろよい"
    var nicknameNoun: String = "ペンギン"
    var gender: String = "male"
    var weeklyGoalGrams: Double = 280
    var dailyGoalGrams: Double = 40
    var language: String = "ja"
    var onboardingCompleted: Bool = false
    var eulaAccepted: Bool = false
    var eulaAcceptedAt: Date? = nil
    var createdAt: Date = Date()
    var blockedUIDs: [String] = []
}
```

### オンボーディング状態の二重管理（Phase 4 までの暫定）

- **`AppState.onboardingCompleted`**（UserDefaults）: アプリ起動時に `ContentView` / `OnboardingContainerView` を切り替えるための軽量フラグ。
- **`UserProfile.onboardingCompleted`**（SwiftData）: 永続プロフィールとしての完了状態。

Phase 0〜3 では UserDefaults のみ更新してもよいが、**Phase 4 でオンボーディング完了フローを実装する際は**、`completeOnboarding()` 等で **両方を同じ値に更新する**、または **UserProfile を真実源**として `AppState` がモデルコンテキストから読み取る形に整理すること（ずれによるバグ防止）。

### Firestore コレクション

**`users/{uid}`**
```json
{ "nickname_flag":"🇯🇵", "nickname_emoji":"🌙",
  "nickname_adjective":"ほろよい", "nickname_noun":"ペンギン",
  "language":"ja", "created_at":"Timestamp" }
```

**`feed/{auto-id}`**
```json
{ "uid":"xxx", "type":"goal_met|rest_day|over_goal|weekly_achieved",
  "actual_grams":20, "goal_grams":40, "percentage":50,
  "drinks":["beer","beer"], "streak_days":5,
  "message_variant":3, "language":"ja",
  "reactions":{"clap":12,"fire":8,"muscle":5,"hug":0,"clover":0,"cheers":0},
  "reacted_uids":["uid1","uid2"], "created_at":"Timestamp" }
```

**`reports/{auto-id}`**
```json
{ "reporter_uid":"xxx", "target_uid":"yyy",
  "target_post_id":"feed-id", "reason":"inappropriate",
  "created_at":"Timestamp" }
```

### Firebase セキュリティルール（強化版）

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == uid;
    }

    match /feed/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid;

      allow update: if request.auth != null
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['reactions', 'reacted_uids'])
        && request.resource.data.reacted_uids.hasAll(resource.data.reacted_uids)
        && request.resource.data.reacted_uids.size() == resource.data.reacted_uids.size() + 1
        && request.resource.data.reacted_uids[request.resource.data.reacted_uids.size() - 1] == request.auth.uid
        && !resource.data.reacted_uids.hasAny([request.auth.uid])
        && reactionsValid(resource.data.reactions, request.resource.data.reactions);

      function reactionsValid(before, after) {
        let validKeys = ['clap', 'fire', 'muscle', 'hug', 'clover', 'cheers'];
        return after.keys().hasAll(validKeys)
          && (
            (after.clap == before.clap + 1 && after.fire == before.fire && after.muscle == before.muscle && after.hug == before.hug && after.clover == before.clover && after.cheers == before.cheers) ||
            (after.clap == before.clap && after.fire == before.fire + 1 && after.muscle == before.muscle && after.hug == before.hug && after.clover == before.clover && after.cheers == before.cheers) ||
            (after.clap == before.clap && after.fire == before.fire && after.muscle == before.muscle + 1 && after.hug == before.hug && after.clover == before.clover && after.cheers == before.cheers) ||
            (after.clap == before.clap && after.fire == before.fire && after.muscle == before.muscle && after.hug == before.hug + 1 && after.clover == before.clover && after.cheers == before.cheers) ||
            (after.clap == before.clap && after.fire == before.fire && after.muscle == before.muscle && after.hug == before.hug && after.clover == before.clover + 1 && after.cheers == before.cheers) ||
            (after.clap == before.clap && after.fire == before.fire && after.muscle == before.muscle && after.hug == before.hug && after.clover == before.clover && after.cheers == before.cheers + 1)
          );
      }
    }

    match /reports/{reportId} {
      allow create: if request.auth != null;
      allow read: if false;
    }
  }
}
```

**ルール設計のトレードオフ:**
- Cloud Functions 不使用 → 月額コストゼロ（Firestore 無料枠内で運用）
- `reacted_uids` は追加のみ許可、削除・上書き不可
- 同一ユーザーの二重リアクションはルールレベルで拒否
- `reactions` カウントは厳密に +1 のみ許可
- 制限: リアクション取り消しは v1.0 では非対応

### クライアント側リアクション実装

```swift
func addReaction(postId: String, reactionType: String, uid: String) async throws {
    let ref = db.collection("feed").document(postId)
    try await ref.updateData([
        "reactions.\(reactionType)": FieldValue.increment(Int64(1)),
        "reacted_uids": FieldValue.arrayUnion([uid])
    ])
}
```

## 画面仕様（全6画面 + 1モーダル + 1オンボーディング）

### オンボーディング（5ステップ）
1. **EULA 同意** — 利用規約・プライバシーポリシーの確認と同意
2. 言語選択（JA/EN — SupportedLanguage.allCases から動的生成）
3. 性別 + 目標確認（厚労省基準自動設定）
4. ニックネーム選択（国旗+絵文字+形容詞+名詞、シャッフル可）
5. → ホームへ遷移

### EULA 同意画面の要件
- 利用規約全文を `Resources/EULA/eula_{lang}.md` から読み込み、ScrollView で表示
- チェックボックス ON で「同意して始める」ボタンが活性化
- 同意時に `UserProfile.eulaAccepted = true` + `eulaAcceptedAt = Date()` を記録
- 同意しない限り次のステップに進めない
- 利用規約には以下を含む: 免責表示、フィード利用ルール、通報・ブロック方針、データ取り扱い

### メインタブ（4タブ + 中央FAB）
```
[🏠ホーム] [📅カレンダー] [➕記録FAB] [🌍みんな] [⚙️設定]
```

### 各画面のレイアウト詳細 → [DESIGN.md](./DESIGN.md)「画面別レイアウト仕様」セクション参照

## ドリンク初期データ

| 種類 | emoji | 初期容量 | 初期度数(%) | ABV fraction | 純AL |
|------|-------|---------|------------|-------------|------|
| ビール | 🍺 | 350ml | 5% | 0.05 | 14g |
| ワイン | 🍷 | 125ml | 12% | 0.12 | 12g |
| 日本酒 | 🍶 | 180ml | 15% | 0.15 | 21.6g |
| ウイスキー | 🥃 | 30ml | 40% | 0.40 | 9.6g |
| カクテル | 🍸 | 200ml | 5% | 0.05 | 8g |
| サワー | 🍹 | 350ml | 5% | 0.05 | 14g |

> ドリンク初期データは `DrinkType` enum 内で `AlcoholByVolume.fromFraction()` を使って定義。
> UI の度数ステッパーでは `AlcoholByVolume.fromPercentage()` を使い、変換ミスを型レベルで防止。

## フィード自動生成テンプレート

4タイプ × 各5-10バリエーション（Localizable.xcstrings で管理）:
- `goal_met`: "今日は目標内！🍺×{n}で{actual}g — 目標{goal}gの{pct}%に抑えたよ🎉"
- `rest_day`: "今日は休肝日！{streak}日連続達成🌿"
- `over_goal`: "今日はオーバー…{actual}g / 目標{goal}g (+{over_pct}%)。明日こそ！💪"
- `weekly_achieved`: "今週クリア！合計{actual}g / 目標{goal}gで{pct}%に収まった🏆"

## ニックネームプリセット
- 国旗 50種 × 絵文字 20種 × 形容詞 30種/言語 × 名詞 30種/言語 = 900,000通り
- JSON ファイルで管理、言語別に形容詞・名詞を切り替え
- 新言語追加時は `adjectives_{lang}.json` + `nouns_{lang}.json` を追加するだけ

## マネタイズロードマップ

| バージョン | MAU | 広告 | 備考 |
|-----------|-----|------|------|
| v1.0 | 0-300 | なし | UX最優先 |
| v1.x | 300-500 | AdMob Banner導入 | FeatureFlag で制御 |
| v2.x | 1,000+ | Banner定常運用 | Apple Dev年会費回収 |

## KPI

| 指標 | 3ヶ月 | 6ヶ月 | 12ヶ月 |
|------|------|------|-------|
| MAU | 30 | 200 | 1,000 |
| 7日リテンション | 20% | 25% | 30% |
| リアクション率 | 10% | 15% | 20% |

## テスト戦略

### テストするもの（MVP 必須）
- **AlcoholByVolume 型変換**: パーセント ↔ 小数の変換精度、境界値、不正値の precondition
- **DrinkRecord 純アルコール計算**: 各ドリンクタイプの計算正確性、複数杯の計算
- **AlcoholCalculator**: 日計・週計・ストリーク・パーセンテージ
- **FeedGenerator**: 4タイプの正しい判定、テンプレート適用
- **Firestore セキュリティルール**: npm エミュレータでのルールユニットテスト

### テストしないもの（MVP では省略）
- UI テスト / スナップショットテスト — 手動確認で代替
- ViewModel のユニットテスト — ロジックは Service 層に集約しているためそちらでカバー
- パフォーマンステスト — MVP の規模では不要
- ネットワークモックテスト — Firestore ルールテストでカバー

### テストファイル一覧
| ファイル | テスト対象 | 最低ケース数 |
|---------|-----------|------------|
| `AlcoholByVolumeTests.swift` | 型変換、境界値、precondition | 6 |
| `DrinkRecordTests.swift` | 純AL計算、全6ドリンクタイプ | 8 |
| `AlcoholCalculatorTests.swift` | 日計・週計・ストリーク | 8 |
| `FeedGeneratorTests.swift` | 4タイプ判定、パーセンテージ | 6 |
| `firestore-rules.test.js` | リアクション正常/二重拒否/不正値拒否 | 8 |

## App Store 審査対策
- HealthKit 未使用 → 医療審査不要
- テキスト入力なし → UGC 1.2 リスク最小
- 通報・ブロック・**EULA 同意フロー**は必須実装済み
- EULA はオンボーディングの最初のステップで同意必須
- 免責表示: 「本アプリは医療アドバイスを提供するものではありません」（EULA 内 + 設定画面）
