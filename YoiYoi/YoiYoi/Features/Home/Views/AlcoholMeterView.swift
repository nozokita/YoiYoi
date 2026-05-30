import SwiftUI

/// DESIGN.md ホーム「メーター」+ 160×160 / 背景リング white 20% / 太さ 14pt。
struct AlcoholMeterView: View {
    let consumed: Double
    let dailyGoal: Double

    @State private var animatedTrim: CGFloat = 0

    private var progress: CGFloat {
        guard dailyGoal > 0 else { return 0 }
        return CGFloat(min(consumed / dailyGoal, 1))
    }

    var body: some View {
        meterRing
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedTrim = progress
            }
        }
        .onChange(of: progress) { _, new in
            withAnimation(.easeOut(duration: 1.2)) {
                animatedTrim = new
            }
        }
    }

    private var meterRing: some View {
        ZStack {
            Circle()
                .stroke(AppColors.pureWhite.opacity(0.2), lineWidth: 14)
            Circle()
                .trim(from: 0, to: animatedTrim)
                .stroke(AppColors.pureWhite, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: AppSpacing.xs) {
                Text(formattedConsumed)
                    .font(AppFonts.meterNumber())
                    .foregroundStyle(AppColors.pureWhite)
                    .contentTransition(.numericText())
                Text("/ \(formattedGoal)")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.pureWhite.opacity(0.7))
            }
        }
        .frame(width: 160, height: 160)
    }

    private var formattedConsumed: String {
        if consumed == floor(consumed) {
            return "\(Int(consumed))g"
        }
        return String(format: "%.1fg", consumed)
    }

    private var formattedGoal: String {
        if dailyGoal == floor(dailyGoal) {
            return "\(Int(dailyGoal))g"
        }
        return String(format: "%.1fg", dailyGoal)
    }

}

#Preview("メーター 50%") {
    ZStack {
        AppGradients.heroHome
        AlcoholMeterView(consumed: 20, dailyGoal: 40)
    }
}
