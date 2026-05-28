import SwiftUI

/// DESIGN.md「主要アクション」。大人向けに厚みを抑え、押しやすさと信頼感を優先する。
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
                        colors: [AppColors.coralRed, AppColors.coralDeep],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(
                    color: isEnabled ? AppColors.coralDeep.opacity(0.22) : .clear,
                    radius: 14,
                    y: 7
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
