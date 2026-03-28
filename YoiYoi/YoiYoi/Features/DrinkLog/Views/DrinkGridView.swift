import SwiftUI

/// DESIGN.md 飲酒記録シート: 2×3 グリッド。選択時 coral 枠 2.5pt + 背景 + scale 1.03。
struct DrinkGridView: View {
    @Binding var selection: DrinkType?
    @EnvironmentObject private var appState: AppState

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
            ForEach(DrinkType.allCases, id: \.self) { type in
                drinkCell(type)
            }
        }
    }

    private func drinkCell(_ type: DrinkType) -> some View {
        let on = selection == type
        return Button {
            selection = type
        } label: {
            VStack(spacing: AppSpacing.sm) {
                Text(type.emoji)
                    .font(.system(size: 40))
                Text(type.shortLabel(for: appState.currentLanguage))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.charcoal)
                Text("\(Int(type.defaultVolumeML))ml")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(AppColors.greyText)
                Text(String(format: "%.1f%%", type.defaultAbv.percentage))
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(AppColors.greyText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(on ? AppColors.coralRed.opacity(0.08) : AppColors.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(on ? AppColors.coralRed : Color.clear, lineWidth: 2.5)
            }
            .scaleEffect(on ? 1.03 : 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct Host: View {
        @State private var sel: DrinkType?
        var body: some View {
            DrinkGridView(selection: $sel)
                .padding()
                .background(AppColors.cream)
        }
    }
    return Host()
        .environmentObject(AppState())
}
