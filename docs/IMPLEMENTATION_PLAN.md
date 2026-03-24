# YoiYoi MVP v1.0 実装計画
> Cursor で Claude Sonnet 4 / Opus 4.6 を使い分けて開発

## AI モデル使い分けの原則

| 状況 | 使うモデル | 理由 |
|------|-----------|------|
| **初期アーキテクチャ設計** | **Opus** | 複数ファイル間の依存関係・設計判断が必要 |
| **新 Feature の骨組み作成** | **Opus** | ViewModel + View + Model を同時に整合させる |
| **個別 View の実装** | **Sonnet** | 単一ファイル、UI パーツの繰り返し作業 |
| **スタイリング・カラー調整** | **Sonnet** | 定義済みトークンの適用、反復作業 |
| **バグ修正（単一ファイル）** | **Sonnet** | 速い。局所的な問題解決 |
| **バグ修正（複数ファイル横断）** | **Opus** | 原因が不明確、複数ファイルの状態追跡が必要 |
| **Firebase ルール・セキュリティ** | **Opus** | セキュリティは高リスク、慎重な推論が必要 |
| **テストコード作成** | **Sonnet** | パターン化された繰り返し |
| **ローカライゼーション** | **Sonnet** | 定型的な翻訳・文字列管理 |
| **レビュー・リファクタリング** | **Opus** | コード全体の品質判断 |
| **JSON データ作成** | **Sonnet** | 単純な列挙作業 |
| **README / ドキュメント** | **Sonnet** | 構造化された文書生成 |

## フェーズ構成（全10フェーズ、約10-14週）

---

### Phase 0: プロジェクト初期セットアップ（1-2日）
**モデル: Opus**

**Cursor プロンプト:**
```
@docs/SPEC.md @docs/DESIGN.md を読み込んで。

以下をこの順番で作成して:

1. YoiYoiApp.swift / YoiYoiAppDelegate.swift
   - `@main` は `YoiYoiApp`（SwiftUI `App` / `WindowGroup`）。Firebase 等は `@UIApplicationDelegateAdaptor(YoiYoiAppDelegate.self)`。
   - SwiftData ModelContainer（DrinkRecord, UserProfile）
   - Firebase の初期化（FirebaseApp.configure()）
   - AppState を @Environment に注入
   - onboardingCompleted に応じて OnboardingContainerView / ContentView を切り替え

2. AppState.swift
   - @Observable class
   - onboardingCompleted: Bool（UserDefaults 永続化）
   - currentLanguage: SupportedLanguage

3. FeatureFlags.swift
   - static let isAdsEnabled = false
   - static let isFeedEnabled = true

4. ContentView.swift
   - TabView with 4 tabs + 中央 FAB
   - タブ: Home, Calendar, Feed, Settings
   - 中央の + ボタンは @docs/DESIGN.md「タブバー仕様」の通り
     56pt 円形、coralRed グラデ、タブバーから上に浮かせる
   - タップで DrinkLogSheet を .sheet 表示

5. Core/Models/SupportedLanguage.swift
   - @docs/SPEC.md の SupportedLanguage enum をそのまま実装
```

**成果物:** アプリが起動し、タブ画面が表示される状態。

---

### Phase 1: テーマシステム + 共通シェイプ（1-2日）
**モデル: Sonnet**

**ステップ 1-1: カラー定義**
```
@docs/DESIGN.md の「カラーパレット」を参照して
UI/Theme/AppColors.swift を作成。
enum AppColors で全色を static let で定義。
Color+Ext.swift に hex イニシャライザも作成。
```

**ステップ 1-2: グラデーション定義**
```
@docs/DESIGN.md の「ヒーローエリア配色」を参照して
UI/Theme/AppGradients.swift を作成。
各画面用のヒーローグラデーション + 全画面グラデーション（オンボーディング用）を定義。
```

**ステップ 1-3: フォント定義**
```
@docs/DESIGN.md のタイポグラフィ表と @docs/SPEC.md の SupportedLanguage を参照して
UI/Theme/AppFonts.swift を作成。
SF Pro Rounded を .design(.rounded) で指定。
言語ごとのフォント切り替えを SupportedLanguage.fontFamily と連動。
ヒーロー見出し（28pt Bold white）やメーター数字（48pt Heavy）も定義。
```

**ステップ 1-4: スペーシング**
```
UI/Theme/AppSpacing.swift を作成。
xs=4, sm=8, md=16, lg=24, xl=32, xxl=48 を定義。
```

**ステップ 1-5: WaveShape**
```
@docs/DESIGN.md の「ウェーブシェイプ仕様」を参照して
UI/Components/WaveShape.swift を作成。
CustomShape として実装。ヒーローエリアの下端クリッピングに使う。
```

**成果物:** 全デザイントークン + ウェーブシェイプが利用可能。

---

### Phase 2: 共通UIコンポーネント（2-3日）
**モデル: Sonnet**（個別パーツ）→ **Opus**（最終レビュー）

**ステップ 2-1: ContentCard**（Sonnet）
```
@docs/DESIGN.md の「① コンテンツカード」を参照して
UI/Components/ContentCard.swift を作成。
白背景 + テーマ色シャドウ。themeColor を引数で受ける。
.contentCard(themeColor:) の ViewModifier として使えるようにして。
```

**ステップ 2-2: GradientAccentCard**（Sonnet）
```
@docs/DESIGN.md の「② グラデーションアクセントカード」を参照して
UI/Components/GradientAccentCard.swift を作成。
参照デザインの科目カードパターン: 横長、左テキスト＋右絵文字、グラデーション背景。
引数: title, subtitle, emoji, gradientColors
```

**ステップ 2-3: PuffyButton**（Sonnet）
```
@docs/DESIGN.md の「ぷっくりボタン仕様」を参照して
UI/Components/PuffyButton.swift を作成。
disabled 状態: opacity 0.5、shadow なし、タップ無効。
```

**ステップ 2-4: StatCard**（Sonnet）
```
UI/Components/StatCard.swift を作成。
引数: title, value, emoji, backgroundColor
数字は AppFonts のメーター数字相当（28pt Heavy）。
背景は薄い色（mintLight / yellowLight / coralLight）。
```

**ステップ 2-5: PillTag**（Sonnet）
```
UI/Components/PillTag.swift を作成。
引数: text, bgColor, textColor, isSelected
cornerRadius 999。
```

**ステップ 2-6: FlagPicker / BounceModifier / ThemedShadowModifier**（Sonnet）
```
UI/Components/FlagPicker.swift — 横スクロール国旗ピッカー。
UI/Modifiers/BounceModifier.swift — タップ時 scaleEffect 0.95。
UI/Modifiers/ThemedShadowModifier.swift — テーマ色シャドウ。
```

**ステップ 2-7: コンポーネントレビュー**（Opus）
```
@UI/Components/ と @UI/Modifiers/ の全ファイルを
@docs/DESIGN.md の「カードスタイル定義」「影ルール」と照合してレビュー。
一貫性・命名規則をチェック。問題があれば修正。
```

**成果物:** 再利用可能な UI パーツが揃い、Preview で確認可能。

---

### Phase 3: データモデル + 純アルコール計算（2日）
**モデル: Opus**（モデル設計）→ **Sonnet**（テスト）

**ステップ 3-1: AlcoholByVolume 型**（Opus）
```
@docs/SPEC.md の「AlcoholByVolume」をそのまま実装。
Core/Models/AlcoholByVolume.swift
```

**ステップ 3-2: SwiftData モデル**（Opus）
```
@docs/SPEC.md の「データモデル」を参照して Core/Models/ 配下に:
- DrinkRecord.swift（init は AlcoholByVolume 型のみ受付）
- UserProfile.swift（eulaAccepted + eulaAcceptedAt 含む）
- DrinkType.swift（enum、ABV は AlcoholByVolume.fromFraction で定義）
- FeedPost.swift（Codable struct）
- NicknamePresets.swift（JSON 読み込み）
```

**ステップ 3-3: 計算サービス**（Sonnet）
```
Core/Services/AlcoholCalculator.swift を作成。
dailyTotal, weeklyTotal, remainingToday, percentage, streakDays
```

**ステップ 3-4: テスト**（Sonnet）
```
Tests/AlcoholByVolumeTests.swift（6ケース）
Tests/DrinkRecordTests.swift（8ケース）
Tests/AlcoholCalculatorTests.swift（8ケース）
```

**成果物:** データモデル + 計算ロジック + テスト。

---

### Phase 4: オンボーディング（3-4日）
**モデル: Opus**（フロー設計）→ **Sonnet**（個別画面）

**ステップ 4-1: フロー設計**（Opus）
```
@docs/SPEC.md の「オンボーディング（5ステップ）」を参照して
Features/Onboarding/ を設計。

OnboardingContainerView.swift:
- @State currentStep: Int (0-4)、5ステップ
- EULA ステップはインジケーターに含めない
- ページインジケーター: coralRed ドット3つ（言語/性別/ニックネーム）

OnboardingViewModel.swift:
- eulaAccepted, selectedLanguage: SupportedLanguage
- selectedGender, weeklyGoal, dailyGoal
- nickname 4パーツ + shuffleNickname()
- acceptEULA(), completeOnboarding()
```

**ステップ 4-2: EULA 画面**（Sonnet）
```
@docs/DESIGN.md の「オンボーディング: EULA 同意画面」を参照して
Features/Onboarding/Views/EULAView.swift を実装。
全画面グラデーション（ウェーブなし）。コンテンツカード内に ScrollView。
```

**ステップ 4-3: 言語選択画面**（Sonnet）
```
@docs/DESIGN.md の「オンボーディング: 言語選択画面」を参照して実装。
SupportedLanguage.allCases から動的にカード生成。
```

**ステップ 4-4: 性別・目標画面**（Sonnet）
```
@docs/DESIGN.md の「オンボーディング: 性別・目標画面」を参照して実装。
Pill 3択 + 目標カード。
```

**ステップ 4-5: ニックネーム選択画面**（Sonnet）
```
@docs/DESIGN.md の「オンボーディング: ニックネーム選択画面」を参照して実装。
4行の横スクロールピッカー + プレビューカード + シャッフルボタン。
```

**成果物:** EULA同意 → 言語 → 性別 → ニックネーム → ホーム遷移。

---

### Phase 5: ホーム画面 + メーター（3-4日）
**モデル: Opus**（ウェーブヒーロー + メーター設計）→ **Sonnet**（サブビュー）

**ステップ 5-1: WaveHeroView + メーター**（Opus）
```
@docs/DESIGN.md の「ホーム画面」を参照して以下を作成。

Features/Home/Views/WaveHeroView.swift:
- 共通ウェーブヒーローエリア（他画面でも再利用）
- 引数: gradientColors, content(@ViewBuilder)
- WaveShape でクリッピング
- height: 画面の約35%

Features/Home/Views/AlcoholMeterView.swift:
- ヒーロー内に配置するメーターリング（160×160）
- 背景リング: white 20%, 太さ 14pt
- 消費リング: white, trim アニメーション
- 中央数字: 48pt Heavy, white
- @docs/DESIGN.md のメーター状態別表現テーブルに従う
```

**ステップ 5-2: HomeView 全体**（Sonnet）
```
@docs/DESIGN.md の「ホーム画面」ASCIIレイアウトを参照して
Features/Home/Views/HomeView.swift を実装。

上部: WaveHeroView（ニックネーム挨拶 + AlcoholMeterView）
下部 ScrollView:
- 今週のまとめカード（StatCard × 3）→ ヒーローに -24pt 重なる
- 今日のドリンクカード（横スクロール Pill）
- みんなの様子カード（フィードプレビュー 2件 + もっと見る →）
```

**ステップ 5-3: HomeViewModel**（Sonnet）
```
Features/Home/ViewModels/HomeViewModel.swift
@Observable, @MainActor
todayConsumed, weeklyConsumed, streakDays, restDaysThisWeek
```

**成果物:** ウェーブヒーロー + メーター + カード群のホーム画面。

---

### Phase 6: 飲酒記録シート（3日）
**モデル: Opus**（フロー設計）→ **Sonnet**（UI）

**ステップ 6-1: 記録フロー設計**（Opus）
```
@docs/DESIGN.md の「飲酒記録シート」を参照してフロー設計。

DrinkLogViewModel:
- ドリンク選択 → 量・度数調整 → 純AL リアルタイム計算
- 度数は AlcoholByVolume.fromPercentage() 経由
- SwiftData 保存 + FeedGenerator でローカル投稿生成（Firestore は Phase 8）
```

**ステップ 6-2: ドリンクグリッド**（Sonnet）
```
@docs/DESIGN.md の「飲酒記録シート」を参照。
2×3 LazyVGrid、選択時 coralRed ボーダー 2.5pt + scale 1.03。
```

**ステップ 6-3: スライダー + 度数**（Sonnet）
```
@docs/DESIGN.md の「飲酒記録シート」調整エリアを参照。
杯数ステッパー + 度数ステッパー（±0.5%）+ 純AL リアルタイム表示（36pt Heavy, coralRed）。
```

**ステップ 6-4: FeedGenerator + テスト**（Sonnet）
```
Core/Services/FeedGenerator.swift
generatePost() → FeedPost を返す（Firestore 非依存）。

Tests/FeedGeneratorTests.swift（6ケース）
```

**成果物:** 記録入力 → ローカル保存 → フィード投稿テンプレート生成。

---

### Phase 7: カレンダー画面（2-3日）
**モデル: Opus**（ウェーブヒーロー統合）→ **Sonnet**（グリッド）

**ステップ 7-1: CalendarView + ヒーロー**（Opus）
```
@docs/DESIGN.md の「カレンダー画面」を参照。
WaveHeroView を mintGreen テーマで再利用。
ヒーロー内にミニバッジ × 3（休肝日/目標内/超過）。
```

**ステップ 7-2: DayCellView + グリッド**（Sonnet）
```
@docs/DESIGN.md の「カレンダー画面」を参照。
44×44 セル、4状態の色ドット、当日 coralRed ボーダーリング。
月切り替え矢印。
```

**ステップ 7-3: 週間棒グラフ**（Sonnet）
```
@docs/DESIGN.md の「今週の推移」カードを参照。
目標ライン（点線）+ 各曜日バー（mintGreen/warmCoral）。
```

**成果物:** ウェーブヒーロー + カレンダー + 棒グラフ。

---

### Phase 8: Firebase + フィード画面（6-8日）★最大の技術チャレンジ
**モデル: Opus**

**ステップ 8-1: Firebase セットアップ**（Opus）
```
Core/Services/AuthService.swift — Anonymous Auth
`YoiYoiAppDelegate.didFinishLaunching` の Firebase 初期化コード更新。
```

**ステップ 8-2: Firestore サービス**（Opus）
```
Core/Services/FirestoreService.swift
@docs/SPEC.md の「クライアント側リアクション実装」参照。
FieldValue.increment(1) + FieldValue.arrayUnion([uid]) を使用。
```

**ステップ 8-3: Phase 6 の FeedGenerator を Firestore に接続**（Opus）
```
DrinkLogViewModel の記録フローに Firestore 書き込みを統合。
エラー時はローカル保存は維持、フィード投稿のみ失敗を許容。
```

**ステップ 8-4: フィード画面**（Opus）
```
@docs/DESIGN.md の「フィード画面」を参照して全画面を実装。

FeedView:
- WaveHeroView を sunnyYellow テーマで使用
- ※ yellow 背景ではテキスト charcoal（@docs/DESIGN.md 指定通り）
- 言語フィルタ PillTag（SupportedLanguage.allCases から動的生成）

FeedCardView:
- コンテンツカード + タイプ別左ボーダー
- @docs/DESIGN.md の「FeedCard タイプ別の視覚的区別」テーブルに従う
- ミニ進捗バー: 高さ 6pt, radius 3
- 「⋯」メニュー: ブロック/通報

ReactionBarView:
- 6種の PillTag、リアクション済みは coralRed fill + white text
```

**ステップ 8-5: セキュリティルール + テスト**（Opus）
```
@docs/SPEC.md の Firebase セキュリティルールを firestore.rules に。
Tests/FirestoreRulesTests/firestore-rules.test.js（8ケース）
Firebase Emulator Suite でテスト。
```

**成果物:** フィード画面 + リアクション + セキュリティルールテスト済み。

---

### Phase 9: 設定画面（2日）
**モデル: Sonnet**

```
@docs/DESIGN.md の「設定画面」を参照して全画面を実装。
WaveHeroView を lavender テーマで使用。
ヒーロー内にプロフィールカード（フロスト）。
下部にコンテンツカード群（目標設定/アプリ設定/ソーシャル/情報）。
免責表示を最下部に。
```

**成果物:** 設定から全パラメータの変更が可能。

---

### Phase 10: ローカライゼーション + 仕上げ + 提出準備（3-4日）
**モデル: Sonnet**（翻訳）→ **Opus**（最終レビュー）

**ステップ 10-1: String Catalog**（Sonnet）
```
MVP は JA / EN の2言語。約260キー。
```

**ステップ 10-2: NicknameData JSON**（Sonnet）
```
6ファイル: flags.json, emojis.json, adjectives/nouns × ja/en
```

**ステップ 10-3: EULA テキスト**（Sonnet）
```
eula_ja.md, eula_en.md
免責事項、フィード利用ルール、通報方針、プライバシーポリシー概要。
```

**ステップ 10-4: App Store 準備**（Sonnet）
```
AppIcon 1024×1024、スクリーンショットテキスト（2言語）、
App Store 説明文（2言語）、プライバシーポリシー。
```

**ステップ 10-5: 最終レビュー**（Opus）
```
プロジェクト全体を @docs/SPEC.md @docs/DESIGN.md と照合。

チェックリスト:
□ 全画面でウェーブヒーローが一貫して使われているか
□ カードスタイルが docs/DESIGN.md の3種（コンテンツ/グラデーション/フロスト）に統一されているか
□ 影が全て画面テーマ色で統一されているか
□ 全テキストがローカライズされているか（JA/EN）
□ AlcoholByVolume が全箇所で使われ、Double の直接渡しがないか
□ Firebase セキュリティルールのテストが全パス
□ リアクションの1ユーザー1回制約が機能するか
□ ブロック・通報が動作するか
□ EULA → オンボーディング → ホーム遷移が正しいか
□ 免責表示が EULA 内 + 設定画面にあるか
□ SupportedLanguage に言語追加時の影響範囲が限定されているか
□ メモリリークや不要な再レンダリングがないか
```

**成果物:** App Store 提出可能な MVP。

---

## 全体タイムライン

| 週 | フェーズ | 主要モデル | 成果物 |
|----|---------|-----------|--------|
| 1 | Phase 0-1 | Opus → Sonnet | 骨格 + テーマ + WaveShape |
| 2 | Phase 2-3 | Sonnet + Opus | コンポーネント + データモデル |
| 3 | Phase 4 | Opus + Sonnet | オンボーディング + EULA |
| 4-5 | Phase 5 | Opus + Sonnet | ホーム + ウェーブヒーロー + メーター |
| 6 | Phase 6 | Opus + Sonnet | 飲酒記録 |
| 7 | Phase 7 | Opus + Sonnet | カレンダー |
| 8-10 | Phase 8 | **Opus** | Firebase + フィード（最重要） |
| 11 | Phase 9 | Sonnet | 設定画面 |
| 12-14 | Phase 10 | Sonnet + Opus | ローカライゼーション + 最終レビュー |

## コスト意識

Sonnet: 全体の約 **65%**（UI パーツ、テスト、翻訳、JSON）
Opus: 全体の約 **35%**（設計、統合、セキュリティ、レビュー）
Cursor の Auto モードは使わず、タスク粒度ごとに手動で切り替える。

## 各フェーズ開始時の共通手順

1. `@docs/SPEC.md` と `@docs/DESIGN.md` を Cursor に読み込ませる
2. 該当フェーズの目的と成果物を伝える
3. 1ステップずつ進め、各ステップ完了後に Preview / ビルド確認
4. 次のステップへ進む前にコミット
