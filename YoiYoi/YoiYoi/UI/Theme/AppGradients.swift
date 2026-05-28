import SwiftUI

/// DESIGN.md のヒーロー配色・オンボーディング用グラデーション。
enum AppGradients {
    static let heroHome = LinearGradient(
        colors: [AppColors.navy, AppColors.coralDeep, AppColors.coralRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroCalendar = LinearGradient(
        colors: [AppColors.successDeep, AppColors.mintGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroSession = LinearGradient(
        colors: [AppColors.warmCoral, AppColors.amber80],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroSettings = LinearGradient(
        colors: [AppColors.darkBg, AppColors.lavender],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// オンボーディング: 低彩度の紙色ベース。言語選択を邪魔しない。
    static let onboardingFullScreen = LinearGradient(
        colors: [AppColors.pureWhite, AppColors.cream, AppColors.mintLight.opacity(0.65)],
        startPoint: .top,
        endPoint: .bottom
    )
}
