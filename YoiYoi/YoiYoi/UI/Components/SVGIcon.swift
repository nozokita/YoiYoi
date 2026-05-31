import SwiftUI

struct SVGIcon: View {
    let icon: YoiYoiIcon
    var size: CGFloat = 20
    var color: Color = AppColors.charcoal

    var body: some View {
        Image(icon.rawValue)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(color)
            .accessibilityHidden(true)
    }
}
