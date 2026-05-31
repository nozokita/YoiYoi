# YoiYoi

楽しく、無理しないペースでアルコール摂取量を記録する iOS アプリです。記録は端末内だけに保存され、日本語・英語に対応します。

## ドキュメント

| ファイル | 内容 |
|----------|------|
| [docs/DESIGN.md](docs/DESIGN.md) | デザイン方針 v2.0（3タブ、クイック記録、日英 UI） |
| [docs/SPEC.md](docs/SPEC.md) | Lean MVP 仕様書 v2.0（端末内保存、日英対応、将来機能） |
| [docs/IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) | Lean MVP への移行と次期実装手順 |
| [docs/DEBUG_WHITE_SCREEN.md](docs/DEBUG_WHITE_SCREEN.md) | 真っ白画面のときの DEBUG 診断パネル・ログの読み方 |

Cursor で実装するときは **`@docs/SPEC.md`** と **`@docs/DESIGN.md`** をコンテキストに含めると、ルールと整合しやすいです。

## アプリ本体

Xcode プロジェクトは [`YoiYoi/`](YoiYoi/) 配下です（`YoiYoi.xcodeproj` を開く）。

## シミュレーターが真っ白になるとき

1. **Simulator を終了**し、ターミナルで `killall Simulator`（必要なら `killall com.apple.CoreSimulator.CoreSimulatorService`）のあと Xcode から再度起動。
2. メニュー **Device → Erase All Content and Settings** で該当デバイスを消去。
3. Xcode で **Product → Clean Build Folder** のあと再ビルド。
4. 画面に「データを開けませんでした」と出る場合は SwiftData のストア破損の可能性があるので、上記の消去またはアプリ削除で対処。
