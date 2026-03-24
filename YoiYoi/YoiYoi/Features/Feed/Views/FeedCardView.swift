import SwiftUI

struct FeedCardView: View {
    let post: FeedPost
    let nickname: FeedUserNickname?
    let relativeTime: String
    let currentUID: String?
    let reactionHighlight: FeedReactionKind?
    let onReaction: (FeedReactionKind) -> Void
    let onRequestBlock: () -> Void
    let onReport: (String) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            leftAccent
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                headerRow
                Text(FeedMessageFormatter.message(for: post))
                    .font(AppFonts.body(for: languageHint, size: 15))
                    .foregroundStyle(AppColors.charcoal)
                    .fixedSize(horizontal: false, vertical: true)
                if post.type != .restDay {
                    miniBarSection
                }
                ReactionBarView(
                    post: post,
                    currentUID: currentUID,
                    highlight: reactionHighlight,
                    onTap: onReaction
                )
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.pureWhite)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .themedShadow(themeColor: AppColors.sunnyYellow, opacity: 0.10, radius: 16, y: 6)
    }

    private var languageHint: SupportedLanguage {
        post.language.hasPrefix("en") ? .en : .ja
    }

    @ViewBuilder
    private var leftAccent: some View {
        let width: CGFloat = {
            switch post.type {
            case .goalMet: return 0
            case .restDay: return 3
            case .overGoal: return 3
            case .weeklyAchieved: return 3
            }
        }()
        if width > 0 {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(accentColor)
                .frame(width: width)
        }
    }

    private var accentColor: Color {
        switch post.type {
        case .restDay: return AppColors.mintGreen
        case .overGoal: return AppColors.warmCoral
        case .weeklyAchieved: return AppColors.sunnyYellow
        case .goalMet: return .clear
        }
    }

    private var headerRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(headerTitle)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.charcoal)
                Text(relativeTime)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.greyText)
            }
            Spacer(minLength: AppSpacing.sm)
            Menu {
                Button("このユーザーをブロック", role: .destructive) {
                    onRequestBlock()
                }
                Menu("この投稿を通報") {
                    Button("不適切な内容") { onReport("inappropriate") }
                    Button("スパム") { onReport("spam") }
                    Button("ハラスメント") { onReport("harassment") }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.greyText)
                    .frame(width: 44, height: 36)
                    .contentShape(Rectangle())
            }
        }
    }

    private var headerTitle: String {
        if let n = nickname {
            "\(n.nicknameFlag)\(n.nicknameEmoji) \(n.compactDisplayName)"
        } else {
            String(post.uid.prefix(8)) + "…"
        }
    }

    private var miniBarSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(AppColors.charcoal.opacity(0.06))
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(barFillColor)
                        .frame(width: max(0, geo.size.width * barRatio))
                }
            }
            .frame(height: 6)

            Text(barCaption)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.greyText)
        }
    }

    private var barRatio: CGFloat {
        guard post.goalGrams > 0 else { return 0 }
        let r = post.actualGrams / post.goalGrams
        return CGFloat(min(max(r, 0), 1.15))
    }

    private var barFillColor: Color {
        switch post.type {
        case .overGoal: return AppColors.warmCoral
        default: return AppColors.mintGreen
        }
    }

    private var barCaption: String {
        let a = String(format: "%.0f", post.actualGrams)
        let g = String(format: "%.0f", post.goalGrams)
        if post.type == .overGoal {
            let p = Int(post.percentage.rounded())
            return "\(a)g / \(g)g (+\(p)%)"
        }
        return "\(a)g / \(g)g"
    }
}
