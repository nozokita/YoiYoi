# YoiYoi

ゆるふわ飲酒トラッカー（iOS）。仕様・デザイン・実装計画は **`docs/`** にまとめています。

## ドキュメント

| ファイル | 内容 |
|----------|------|
| [docs/DESIGN.md](docs/DESIGN.md) | デザインシステム v5.0（ウェーブヒーロー、カード、画面レイアウト） |
| [docs/SPEC.md](docs/SPEC.md) | 仕様書 v5.0（MVP、アーキテクチャ、データモデル、Firebase） |
| [docs/IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) | Phase 0〜10 の実装手順と Cursor プロンプト例 |
| [docs/FIREBASE_AND_SIMULATOR_LOGS.md](docs/FIREBASE_AND_SIMULATOR_LOGS.md) | Firebase I-COR000003・`load_eligibility_plist` と白画面の切り分け |
| [docs/DEBUG_WHITE_SCREEN.md](docs/DEBUG_WHITE_SCREEN.md) | 真っ白画面のときの DEBUG 診断パネル・ログの読み方 |

Cursor で実装するときは **`@docs/SPEC.md`** と **`@docs/DESIGN.md`** をコンテキストに含めると、ルールと整合しやすいです。

## アプリ本体

Xcode プロジェクトは [`YoiYoi/`](YoiYoi/) 配下です（`YoiYoi.xcodeproj` を開く）。

## シミュレーターが真っ白になるとき

1. **Simulator を終了**し、ターミナルで `killall Simulator`（必要なら `killall com.apple.CoreSimulator.CoreSimulatorService`）のあと Xcode から再度起動。
2. メニュー **Device → Erase All Content and Settings** で該当デバイスを消去。
3. Xcode で **Product → Clean Build Folder** のあと再ビルド。
4. 画面に「データを開けませんでした」と出る場合は SwiftData のストア破損の可能性があるので、上記の消去またはアプリ削除で対処。
