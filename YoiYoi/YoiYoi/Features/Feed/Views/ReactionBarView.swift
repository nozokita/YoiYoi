import SwiftUI

struct ReactionBarView: View {
    let post: FeedPost
    let currentUID: String?
    let highlight: FeedReactionKind?
    let onTap: (FeedReactionKind) -> Void

    private var reactedByMe: Bool {
        guard let currentUID else { return false }
        return post.reactedUIDs.contains(currentUID)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(FeedReactionKind.allCases) { kind in
                    reactionPill(kind)
                }
            }
            .padding(.vertical, 2)
        }
        /// フィードの縦 `ScrollView` 内でネストするため高さを固定（未確定だとレイアウトが潰れることがある）。
        .frame(height: 44)
    }

    private func reactionPill(_ kind: FeedReactionKind) -> some View {
        let count = kind.count(for: post)
        let isMine = highlight == kind && reactedByMe
        return Button {
            onTap(kind)
        } label: {
            Text("\(kind.emoji)\(count)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(isMine ? AppColors.pureWhite : AppColors.greyText)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(isMine ? AppColors.coralRed : AppColors.pureWhite)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(reactedByMe)
        .accessibilityLabel("\(kind.emoji) \(count)")
    }
}
