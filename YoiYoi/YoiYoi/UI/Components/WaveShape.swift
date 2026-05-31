import SwiftUI

/// DESIGN.md「ウェーブシェイプ仕様」。ヒーロー下端のクリッピングに使用。
struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.88))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.82),
            control1: CGPoint(x: rect.width * 0.35, y: rect.height * 1.08),
            control2: CGPoint(x: rect.width * 0.65, y: rect.height * 0.68)
        )
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.closeSubpath()
        return path
    }
}
