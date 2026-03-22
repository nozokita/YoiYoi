import SwiftUI

/// DESIGN.md「ウェーブヒーロー」— 共通再利用。`WaveShape` で下端クリップ、高さは呼び出し側で指定（目安 画面の約35%）。
struct WaveHeroView<Content: View>: View {
    let height: CGFloat
    let gradient: LinearGradient
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .top) {
            gradient
            content()
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipShape(WaveShape())
    }
}

#Preview {
    WaveHeroView(height: 280, gradient: AppGradients.heroHome) {
        Text("プレビュー")
            .font(AppFonts.heroTitle())
            .foregroundStyle(.white)
    }
    .background(AppColors.cream)
}
