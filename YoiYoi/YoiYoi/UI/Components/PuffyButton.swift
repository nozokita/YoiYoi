import SwiftUI

/// DESIGN.md「ぷっくりボタン仕様」。無効時は opacity 0.5・シャドウなし。
struct PuffyButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.buttonLabel())
                .foregroundStyle(AppColors.pureWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(
                    LinearGradient(
                        colors: [AppColors.coralLight, AppColors.coralRed],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(
                    color: isEnabled ? AppColors.coralDeep.opacity(0.3) : .clear,
                    radius: 12,
                    y: 6
                )
                .opacity(isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.bounceOnTap)
        .disabled(!isEnabled)
    }
}

#Preview("PuffyButton") {
    VStack(spacing: AppSpacing.lg) {
        PuffyButton(title: "つぎへ", isEnabled: true) {}
        PuffyButton(title: "無効", isEnabled: false) {}
    }
    .padding()
    .background(AppColors.cream)
}
