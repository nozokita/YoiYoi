# Phase 3: Analytics, Unlocks, and Growth Spec

> 最終更新: 2026.06.01  
> 目的: 飲酒記録のプライバシーを守りながら、DAU/MAU、継続率、解禁、課金導線をデータドリブンに改善する。

## 1. 基本方針

- 飲酒記録、正確な飲酒日時、AIコメント全文、自由入力、医療・健康状態は外部送信しない。
- 実用機能と安全寄りのAI支援は無料で維持する。
- 解禁・課金は、口調、キャラ、表情、テーマ、演出、ウィジェットなど「楽しく続ける表現」に寄せる。
- 広告SDK、IDFA、第三者データ連携、データブローカー連携は採用しない。
- Phase 3 では外部分析SDKではなく、自前の最小 analytics API を使う。

## 2. ユーザー価値と課金境界

### 無料コア

- 休肝日提案。
- 控えめ提案。
- 記録直後コメント。
- 昨日/今週の基本振り返り。
- 飲酒記録、編集、削除。
- 目安設定。
- カレンダー振り返り。
- よく飲むドリンクのワンタップ記録。
- 最近記録した内容の再利用。
- 飲み会モード、水分補給リマインダー。
- 日本語/英語切り替え。
- 基本AIコメント、基本キャラ、基本口調。

### 解禁/課金対象

- 口調の種類。
- キャラクター。
- 表情差分。
- テーマカラー。
- より豊かな言い回し。
- キャラごとの掛け合い。
- 限定キャラ。
- 限定テーマ。
- セリフ量。
- 演出。
- 将来的なウィジェット。

### 解禁思想

- 累積カウントアップは「飲んだ・飲まないを問わず、正直に記録して自分と向き合った日」の累積日数。
- 飲みすぎた日も、正直に記録すれば1カウント。
- 累積は途切れてもゼロに戻らない。
- 一度解禁した口調・キャラ・テーマは失われない。
- 連続記録は飾りとして表示し、解禁・課金に連動させない。

## 3. ターゲットとアクセシビリティ

- 初期ASO/デザイン上の主ターゲット: 20〜40代。
- 実利用対象: 20歳以上の成人全般。
- UIは50〜70代でも読める文字サイズ・操作性を維持する。
- Dynamic Type、44pt以上のタップ領域、十分なコントラスト、短い文言を標準とする。
- 色だけで状態を伝えず、目安未満/付近/超過などのテキストも併記する。

## 4. キャラクター方針

- `ドクター` は採用しない。医療専門家に見える名称や表現を避ける。
- データ寄りの役割は `アナリスト` / `データさん` として設計する。
- どのキャラも飲酒を勧めず、医療・安全・許容量の断定をしない。
- 辛口系も人格否定、羞恥、脅し、依存を煽る表現は禁止する。
- 恋人風は過度な親密さや依存感を避け、軽い甘やかしに留める。

### 初期候補

| 名称 | 役割 | 解禁 |
|------|------|------|
| なごみ | 基本。穏やかで中立 | 無料 |
| アナリスト | データを落ち着いて読み解く | 累積/課金 |
| データさん | 数字をやわらかく翻訳する | 累積/課金 |
| ギャル | 明るくフランク | 累積/課金 |
| 友達 | 標準的で使いやすい | 無料または序盤解禁 |
| 見守り | やさしい励まし | 無料または序盤解禁 |
| ツンデレ | 遊び心。角を立てない | 累積/課金 |
| クイーン/キング | 凛とした辛口 | 後半解禁/課金 |
| セバス | 丁寧で落ち着いた執事/メイド系 | 累積/課金 |
| にゃん | 脱力・癒し | 累積/課金 |

## 5. Analytics Phase

### Phase 1: Local Telemetry

状態: 実装済み。

- SwiftData に `TelemetryEvent` を保存する。
- 最大 1,000 件を保持する。
- 外部送信なし。
- 目的は実機確認、開発中の挙動把握、将来の送信イベント設計。

### Phase 2: Apple Analytics + Explicit Opt-in

- App Store Connect Analytics で Active Devices、Sessions、Retention、Crashes を見る。
- アプリ内に「匿名の利用状況データを送信して改善に協力する」設定を追加する。
- 初期公開時にONへ誘導しすぎず、ユーザーが理解して選べる文言にする。
- オプトインしないユーザーは、現行どおり端末内 telemetry のみ。
- オプトアウト時は未送信キューを削除し、以降の送信を停止する。

### Phase 3: Self-hosted Minimal Analytics

- 自前の `POST /v1/events` に匿名イベントを送る。
- 外部分析SDKは使わない。
- イベントはバッチ送信し、失敗時は短期間だけ再試行する。
- TLS必須。
- サーバーログにIPアドレスやUser-Agentを長期保存しない。
- Raw event の保持は原則30日以内。その後は日次集計に落とす。
- DAU/MAU、D1/D7/D30 retention、onboarding funnel、logging funnel、unlock funnel、paywall funnel を集計する。

## 6. Analytics Identifier

- `analyticsInstallID` はアプリ初回起動時に生成するランダムUUID。
- アカウント、Apple ID、IDFA、連絡先、位置情報、飲酒記録IDと紐付けない。
- アプリ内設定から analytics をOFFにした場合、送信停止とローカルキュー削除を行う。
- 「分析IDをリセット」を設定に追加し、以後は別ユーザーとして集計されるようにする。
- 既存の集計済みデータは匿名集計として残る可能性をプライバシーポリシーに明記する。

## 7. Event Schema

```json
{
  "schema_version": "1",
  "event_id": "UUID",
  "event_name": "drink_log_saved",
  "occurred_at": "2026-06-01T10:00:00Z",
  "analytics_install_id": "UUID",
  "app_version": "1.0.0",
  "build_number": "1",
  "platform": "iOS",
  "device_family": "iPhone",
  "language": "ja",
  "region": "JP",
  "days_since_install": 3,
  "attributes": {
    "screen": "drink_log",
    "mode": "create",
    "grams_band": "10_19",
    "today_ratio_band": "40_79"
  }
}
```

## 8. Event Taxonomy

### Core

- `app_open`
- `app_backgrounded`
- `screen_viewed`
- `tab_selected`
- `onboarding_started`
- `onboarding_completed`
- `settings_opened`
- `language_changed`

### Drink Logging

- `drink_log_opened`
- `drink_log_saved`
- `drink_log_updated`
- `drink_log_deleted`
- `quick_record_saved`
- `quick_record_undone`
- `favorite_added`
- `favorite_removed`

### AI

- `ai_comment_rendered`
- `ai_comment_refreshed`
- `ai_style_selected`
- `ai_character_selected`
- `ai_comment_context`

`ai_comment_context` は `rest_day_suggestion`、`weekly_adjustment`、`post_log`、`drink_type_trend` などのカテゴリだけを送る。本文は送らない。

### Unlocks and Monetization

- `honest_day_counted`
- `streak_updated`
- `unlock_available`
- `unlock_claimed`
- `paywall_viewed`
- `purchase_started`
- `purchase_completed`
- `purchase_failed`
- `purchase_restored`

### Sessions and Notifications

- `session_started`
- `session_ended`
- `hydration_reminder_scheduled`
- `hydration_reminder_opened`
- `notification_permission_prompted`
- `notification_permission_result`

## 9. Attributes Rules

### Allowed

- `screen`
- `source`
- `mode`
- `language`
- `personality`
- `character_id`
- `theme_id`
- `grams_band`
- `today_ratio_band`
- `week_ratio_band`
- `days_since_install`
- `unlock_day_bucket`
- `session_duration_band`
- `notification_permission`

### Forbidden

- exact grams
- exact drink timestamp
- drink record ID
- free text
- AI comment text
- location
- contact
- account ID
- IDFA
- IP-derived location stored as an attribute
- health/medical condition

## 10. Privacy and App Store Requirements

- Phase 3 公開前に `docs/legal/privacy.html` を更新する。
- App Store Connect の App Privacy Details を更新する。
- Usage Data、Identifiers、Diagnostics の該当有無を確認する。
- Tracking は行わない。第三者広告やデータブローカーと連携しない。
- Privacy Choices URL またはアプリ内設定で、analytics のON/OFFとIDリセットを提供する。
- App Store紹介文は「飲酒記録は端末内だけに保存」を維持し、「任意で許可した場合のみ、匿名の利用状況データを送信できます」と補足する。

## 11. Backend Requirements

- `POST /v1/events`: イベントバッチ受信。
- `GET /health`: 死活監視。
- スキーマ検証に失敗したイベントは保存しない。
- 1 install ID あたりのレート制限を設ける。
- Raw event は30日以内に削除する。
- 日次集計テーブルを作る。
- 管理画面は認証必須。
- サーバーログは短期保持にし、IPアドレスの長期保存を避ける。
- バックアップにも保持期間を設定する。

## 12. Dashboard Metrics

- DAU。
- MAU。
- DAU/MAU。
- Sessions per active install。
- D1/D7/D30 retention。
- Onboarding completion rate。
- First drink log conversion。
- Quick record usage rate。
- AI refresh rate。
- Rest day suggestion exposure rate。
- Unlock claim rate。
- Paywall conversion。
- Purchase conversion。
- Opt-in rate。
- Opt-out rate。

## 13. Implementation Tasks

### Epic A: Product and Privacy Decisions

- [ ] App Store 文言を「飲酒記録は端末内保存」「匿名analyticsは任意」に更新する。
- [ ] Privacy Policy を Phase 3 用に更新する。
- [ ] App Privacy Details の回答案を作る。
- [ ] analytics を初回オンボーディングで聞くか、設定画面から任意ONにするか決める。
- [ ] analytics データ保持期間を確定する。

### Epic B: App Data Model

- [ ] `UserProfile` に `analyticsOptIn` を追加する。
- [ ] `UserProfile` に `analyticsInstallID` または別モデルを追加する。
- [ ] `UserProfile` に `analyticsIDResetAt` を追加する。
- [ ] `TelemetryEvent` に `sentAt`、`sendAttemptCount`、`lastSendError` を追加する。
- [ ] ローカル telemetry のイベント名と属性を Phase 3 taxonomy に合わせて整理する。

### Epic C: Consent UI

- [ ] 設定に「プライバシーと利用状況データ」を追加する。
- [ ] analytics ON/OFF トグルを追加する。
- [ ] 分析IDリセットを追加する。
- [ ] 送信されるもの/送信されないものを短く説明する。
- [ ] JA/EN 文言を追加する。

### Epic D: Analytics Client

- [ ] `AnalyticsClient` を追加する。
- [ ] イベントをバッチ化する。
- [ ] opt-in のときだけ送信する。
- [ ] 失敗時の再試行とバックオフを実装する。
- [ ] Wi-Fi/モバイル通信を問わず軽量に動くよう送信頻度を制限する。
- [ ] アプリ起動時、バックグラウンド移行時、一定件数到達時にflushする。
- [ ] forbidden attributes を送れないよう型で制限する。

### Epic E: Backend

- [ ] `POST /v1/events` を実装する。
- [ ] schema validation を実装する。
- [ ] rate limiting を実装する。
- [ ] raw event store を実装する。
- [ ] daily aggregate job を実装する。
- [ ] raw event deletion job を実装する。
- [ ] admin dashboard 認証を実装する。
- [ ] server log retention を設定する。

### Epic F: Dashboard

- [ ] DAU/MAU を表示する。
- [ ] retention cohort を表示する。
- [ ] onboarding funnel を表示する。
- [ ] drink logging funnel を表示する。
- [ ] AI comment engagement を表示する。
- [ ] unlock/paywall funnel を表示する。
- [ ] opt-in/opt-out rate を表示する。

### Epic G: Unlocks and Monetization

- [ ] 累積カウントアップのモデルを追加する。
- [ ] honest day 判定を実装する。
- [ ] unlock state を追加する。
- [ ] 口調/キャラ/テーマのロック状態をUIに出す。
- [ ] 買い切りの StoreKit 商品を定義する。
- [ ] purchase / restore を実装する。
- [ ] 限定キャラ/限定テーマの導線を設計する。

### Epic H: Character and Copy

- [ ] `ドクター` を仕様・コード・文言から除外する。
- [ ] `アナリスト` と `データさん` の文体定義を作る。
- [ ] 無料コアのAIコメントテンプレートを整理する。
- [ ] 解禁/課金口調のテンプレートを追加する。
- [ ] キャラごとのセリフ安全ルールをテスト化する。

### Epic I: QA and Release

- [ ] analytics OFF で一切通信しないことを確認する。
- [ ] analytics ON で forbidden attributes が送られないことを確認する。
- [ ] オプトアウト後に未送信キューが消えることを確認する。
- [ ] IDリセット後に新IDで送信されることを確認する。
- [ ] App Store Connect の Privacy Details を更新する。
- [ ] TestFlight で同意UIと設定導線を確認する。
- [ ] 審査メモに「飲酒記録は端末内、任意analyticsは匿名・粗粒度」と記載する。

## 14. Release Gate

Phase 3 は以下を満たすまで公開しない。

- Privacy Policy が実装と一致している。
- App Privacy Details が実装と一致している。
- analytics OFF で外部送信が発生しない。
- forbidden data が送信されないことをテストで確認済み。
- raw event の削除ジョブが動いている。
- 管理画面が認証で保護されている。
- 買い切り課金は実用機能をロックしていない。
