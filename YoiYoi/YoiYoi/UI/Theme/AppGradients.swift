import SwiftUI

/// DESIGN.md のヒーロー配色・オンボーディング用グラデーション。
enum AppGradients {
    static let heroHome = LinearGradient(
        colors: [AppColors.coralRed, AppColors.coralLight],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroCalendar = LinearGradient(
        colors: [AppColors.mintGreen, AppColors.mintLight],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroFeed = LinearGradient(
        colors: [AppColors.sunnyYellow, AppColors.yellowLight],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroSettings = LinearGradient(
        colors: [AppColors.lavender, AppColors.lavenderLight],
        startPoint: .top,
        endPoint: .bottom
    )

    /// オンボーディング: coralRed → coralLight → cream（縦・ウェーブなし）。
    static let onboardingFullScreen = LinearGradient(
        colors: [AppColors.coralRed, AppColors.coralLight, AppColors.cream],
        startPoint: .top,
        endPoint: .bottom
    )
}
