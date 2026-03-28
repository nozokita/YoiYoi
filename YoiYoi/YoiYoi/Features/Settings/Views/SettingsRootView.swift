import SwiftUI

/// DESIGN.md「設定画面」テーマ（lavender）— `HomeView` と同型の固定ヒーロー + 下段スクロール。
struct SettingsRootView: View {
    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight() }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WaveHeroView(height: heroHeight, gradient: AppGradients.heroSettings) {
                    VStack(spacing: AppSpacing.md) {
                        Text("設定")
                            .font(AppFonts.heroTitle())
                            .foregroundStyle(AppColors.pureWhite)
                        Text("アプリとデータの管理")
                            .font(AppFonts.heroSubtitle())
                            .foregroundStyle(AppColors.pureWhite.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, AppSpacing.lg)
                }
                .frame(height: heroHeight)
                .frame(maxWidth: .infinity)

                List {
                    Section {
                        Text("目標・言語・通知などの項目は順次ここに追加します。")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.greyText)
                            .listRowBackground(AppColors.cream)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(AppColors.cream)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.cream)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    SettingsRootView()
}
