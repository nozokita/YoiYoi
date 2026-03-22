import SwiftUI

/// 横スクロールの国旗（絵文字）ピッカー。DESIGN.md ニックネーム画面: 選択時 coralRed 枠 2.5pt。
struct FlagPicker: View {
    struct Item: Identifiable, Hashable {
        let id: String
        let emoji: String
    }

    let items: [Item]
    @Binding var selection: String?
    var themeColor: Color = AppColors.coralRed

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(items) { item in
                    let isOn = selection == item.id
                    Button {
                        selection = item.id
                    } label: {
                        Text(item.emoji)
                            .font(.system(size: 28))
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.id)
                    .accessibilityAddTraits(isOn ? .isSelected : [])
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColors.pureWhite.opacity(0.001))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isOn ? themeColor : Color.clear, lineWidth: 2.5)
                    }
                }
            }
            .padding(.vertical, AppSpacing.xs)
        }
    }
}

private struct FlagPickerPreviewHost: View {
    @State private var selection: String? = "ja"

    var body: some View {
        FlagPicker(
            items: [
                .init(id: "ja", emoji: "🇯🇵"),
                .init(id: "en", emoji: "🇺🇸"),
                .init(id: "gb", emoji: "🇬🇧"),
                .init(id: "fr", emoji: "🇫🇷"),
                .init(id: "de", emoji: "🇩🇪")
            ],
            selection: $selection
        )
        .padding()
        .background(AppColors.cream)
    }
}

#Preview("FlagPicker") {
    FlagPickerPreviewHost()
}
