import SwiftUI

extension Color {
    /// 16進文字列（`#RRGGBB` または `RRGGBB`）から色を生成する。
    init(hex: String, alpha: Double = 1) {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&value), sanitized.count == 6 else {
            self = Color(red: 0, green: 0, blue: 0, opacity: alpha)
            return
        }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b, opacity: alpha)
    }

    /// 0xRRGGBB 形式の整数から色を生成する。
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, opacity: alpha)
    }
}
