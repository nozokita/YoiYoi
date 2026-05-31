# YoiYoi App Store 公開チェックリスト

> 最終更新: 2026.05.31  
> 方針: v1.0 は外部分析 SDK、広告 SDK、アカウント、クラウド同期を入れず、記録と telemetry は端末内だけに保存する。

## 0. 公開前の判断

- 初回公開は **無料・広告なし・手動リリース** を推奨する。
- App Review Notes には「飲酒を促進するアプリではなく、ユーザーが自分の記録とペースを把握するためのローカル記録アプリ」と明記する。
- AIコメントは医療アドバイスや診断ではなく、端末内の記録に基づく短い目安コメントであることを説明する。

## 1. Apple Developer Program

- Apple Developer Program に登録する。
- App Store Connect の担当者に必要な権限を付与する。公開作業には Account Holder、Admin、App Manager、Developer などの権限が関係する。
- Bundle ID は `Nozo.YoiYoi` を使う。変更する場合は App Store Connect 登録前に決め切る。

## 2. 証明書と署名

- Xcode の **Signing & Capabilities** で Team を選び、まずは **Automatically manage signing** を使う。
- 手動管理にする場合は、Apple Developer の Certificates, Identifiers & Profiles で以下を用意する。
- Development 用: Apple Development 証明書と Development provisioning profile。
- App Store 配信用: Apple Distribution 証明書と App Store Connect provisioning profile。
- App Store Connect provisioning profile は explicit App ID と distribution certificate に紐づく。Xcode の自動署名を使う場合、配信用 profile は Xcode が管理できる。

## 3. App Store Connect にアプリ登録

- App Store Connect > Apps > New App でアプリレコードを作成する。
- 入力項目:
  - Platform: iOS
  - Name: YoiYoi
  - Primary Language: Japanese または English
  - Bundle ID: `Nozo.YoiYoi`
  - SKU: 任意の一意な文字列
  - User Access: Full Access
- App Information で Category、Content Rights、Age Rating を設定する。
- Privacy Policy URL は `https://nozokita.github.io/YoiYoi/legal/privacy.html` を指定する。

## 4. App Privacy Details

- 現行実装では、飲酒記録、設定、AIコメント用の集計値、telemetry は端末外へ送信しない。
- Apple の App Privacy Details では「collect」は、開発者または第三者がアクセスできる形で端末外へ送信されることを指すため、現行版は **Data Not Collected** を前提に回答する。
- 将来、広告 SDK、外部 analytics、クラッシュレポート、リモート設定、クラウド同期を入れる場合は、リリース前に Privacy Policy URL と App Privacy Details を更新する。
- Third-party SDK を追加する場合は、その SDK の privacy manifest と署名要件も確認する。

## 5. メタデータ

- 日本語と英語の両方を用意する。
- 必須・準必須項目:
  - App name: 30文字以内
  - Subtitle: 30文字以内
  - Promotional Text
  - Description
  - Keywords
  - Support URL
  - Privacy Policy URL
  - Copyright
  - Review contact
- 紹介文では「記録は端末だけに保存」を明確に訴求する。
- 医療効果、安全量、断酒治療、診断のような表現は避ける。

## 6. スクリーンショット

- App Store Connect は iPhone 向けに 1〜10 枚の `.jpg` / `.jpeg` / `.png` スクリーンショットを受け付ける。
- まず 6.9 inch の最高解像度スクリーンショットを用意する。必要に応じて 6.5 inch なども追加する。
- 推奨構成:
  - ホーム: 今日のアルコール量とAIコメント
  - 記録: 量・度数を調整して保存
  - カレンダー: 休肝日・目安内・超過の振り返り
  - 設定: 言語・AIコメント・プライバシー
- スクリーンショット内にも「記録は端末内だけ」を1枚入れると、信頼訴求が強い。

## 7. Archive とアップロード

- Xcode で Version と Build を更新する。
- Destination を **Any iOS Device (arm64)** または実機にする。
- Product > Archive を実行する。
- Organizer で Validate App を通す。
- Distribute App > App Store Connect > Upload でアップロードする。
- App Store Connect で処理完了メールを待ち、Build が選択可能になることを確認する。

## 8. TestFlight

- Internal Testing に開発メンバーを追加する。
- 最低限の確認:
  - 初回オンボーディング
  - 日本語/英語切り替え
  - 記録追加・編集・削除
  - クイック記録
  - カレンダー集計
  - AIコメント更新
  - 飲み会モードとローカル通知
  - プライバシーポリシーリンク
- 外部テスターを使う場合は Beta App Review を通す。

## 9. 審査提出

- Build を選択する。
- Export Compliance、Content Rights、Advertising Identifier を回答する。
- 現行版は広告 SDK なしのため IDFA は使用しない。
- Review Notes に以下を記載する。
  - すべての飲酒記録と telemetry は端末内保存で、サーバー送信なし。
  - AIコメントは医療助言ではなく、記録を見やすくする補助コメント。
  - アプリは過度な飲酒を促進せず、休肝日・水分補給・ペース調整を促す。
- 初回は **Manual Release** にして、承認後に公開タイミングを選ぶ。

## 10. 公開後

- App Store Connect のクラッシュ、レビュー、インストール推移を確認する。
- アプリ内 telemetry は現状ローカルのみなので、ユーザー全体の利用傾向は取得できない。外部 analytics を導入する場合は、先にプライバシー方針を再設計する。
- レビュー文言で「医療」「治療」「依存症改善」などの期待が出てきた場合は、App Store 文面とアプリ内注意書きをさらに明確にする。

## 公式リファレンス

- [App privacy details on the App Store](https://developer.apple.com/app-store/app-privacy-details/)
- [Add a new app](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app)
- [Create an App Store Connect provisioning profile](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile)
- [Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds)
- [Upload app previews and screenshots](https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots)
- [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
- [TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
