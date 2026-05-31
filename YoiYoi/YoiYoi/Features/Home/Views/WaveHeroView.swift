import SwiftUI

/// DESIGN.md「ウェーブヒーロー」— 共通再利用。高さは呼び出し側で指定（目安 画面の約35%）。
/// 下端の流線は **背景グラデのみ** `WaveShape` でクリップする。`clipShape` を `ZStack` 全体にかけると円形メーター等の前景まで欠けるため、前景はクリップしない。
/// ヒーローは **固定 `frame` + 親の先頭** に置き、`GeometryReader` 内 `ScrollView` 直下には置かない — `docs/DEBUG_WHITE_SCREEN.md`。
struct WaveHeroView<Content: View>: View {
    let height: CGFloat
    let gradient: LinearGradient
    let topSafeAreaInset: CGFloat
    @ViewBuilder var content: () -> Content

    init(
        height: CGFloat,
        gradient: LinearGradient,
        topSafeAreaInset: CGFloat = WaveHeroView.currentTopSafeAreaInset,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.height = height
        self.gradient = gradient
        self.topSafeAreaInset = topSafeAreaInset
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(gradient)
                .clipShape(WaveShape())
            content()
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md + topSafeAreaInset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .top)
    }

    private static var currentTopSafeAreaInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
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
