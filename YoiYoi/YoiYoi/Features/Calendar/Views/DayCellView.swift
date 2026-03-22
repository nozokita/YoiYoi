import SwiftUI

/// DESIGN.md: 44×44、radius 16、8pt ドット、当日 coral 枠 2pt。
struct DayCellView: View {
    let dayNumber: Int
    let visual: CalendarDayVisualState
    let isToday: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(backgroundFill)

            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.system(size: 14, weight: visual == .empty ? .regular : .semibold, design: .rounded))
                    .foregroundStyle(visual == .empty ? AppColors.greyText : AppColors.charcoal)

                if visual == .underGoal || visual == .overGoal {
                    Circle()
                        .fill(visual == .underGoal ? AppColors.mintGreen : AppColors.warmCoral)
                        .frame(width: 8, height: 8)
                } else {
                    Color.clear.frame(width: 8, height: 8)
                }
            }
        }
        .frame(width: 44, height: 44)
        .overlay {
            if isToday {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.coralRed, lineWidth: 2)
            }
        }
    }

    private var backgroundFill: Color {
        switch visual {
        case .restDay:
            return AppColors.mintLight.opacity(0.75)
        default:
            return AppColors.pureWhite.opacity(0.001)
        }
    }
}

#Preview {
    HStack {
        DayCellView(dayNumber: 3, visual: .underGoal, isToday: false)
        DayCellView(dayNumber: 4, visual: .restDay, isToday: false)
        DayCellView(dayNumber: 5, visual: .overGoal, isToday: true)
    }
    .padding()
    .background(AppColors.cream)
}
