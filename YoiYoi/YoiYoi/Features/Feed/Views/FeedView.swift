import SwiftData
import SwiftUI

/// DESIGN.md「フィード画面」— sunny ウェーブヒーロー + 言語 Pill + FeedCard。
/// レイアウトは `HomeView` と同型（固定高ヒーロー + 下段 `ScrollView`）。
struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @Query private var profiles: [UserProfile]
    @State private var viewModel = FeedViewModel()
    @State private var blockConfirmUID: String?
    @State private var blockConfirmName: String = ""

    private var blockedUIDs: Set<String> {
        Set(profiles.first?.blockedUIDs ?? [])
    }

    private var heroHeight: CGFloat { WaveHeroLayout.heroHeight() }

    /// `HomeView` / `CalendarView` と同型。ヒーローを `ScrollView` の外に置く。
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WaveHeroView(height: heroHeight, gradient: AppGradients.heroFeed) {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text(AppCopy.feedHeroTitle(appState.currentLanguage))
                            .font(AppFonts.heroTitle())
                            .foregroundStyle(AppColors.charcoal)
                        Text(AppCopy.feedHeroSubtitle(appState.currentLanguage))
                            .font(AppFonts.heroSubtitle())
                            .foregroundStyle(AppColors.charcoal.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, AppSpacing.lg)
                }
                .frame(height: heroHeight)
                .frame(maxWidth: .infinity)

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        languageFilterRow
                        feedList
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    /// 負の top はピル行ごとヒーロー波の下に潜り、クリーム背景に隠れて見切れる原因になる。
                    /// ピルは常に波より下のクリーム上に置く。
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xxl)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cream)
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(AppColors.cream)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.cream)
            .navigationTitle(AppCopy.feedNavTitle(appState.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.startListening()
            }
            .onDisappear {
                viewModel.stopListening()
            }
            .alert(AppCopy.feedBlockAlertTitle(appState.currentLanguage), isPresented: Binding(
                get: { blockConfirmUID != nil },
                set: { if !$0 { blockConfirmUID = nil } }
            )) {
                Button(AppCopy.feedCancel(appState.currentLanguage), role: .cancel) { blockConfirmUID = nil }
                Button(AppCopy.feedBlock(appState.currentLanguage), role: .destructive) {
                    if let uid = blockConfirmUID {
                        viewModel.blockUser(uid, modelContext: modelContext)
                    }
                    blockConfirmUID = nil
                }
            } message: {
                Text(blockConfirmName)
            }
            .alert(AppCopy.feedReactionAlertTitle(appState.currentLanguage), isPresented: Binding(
                get: { viewModel.reactionFailed },
                set: { if !$0 { viewModel.reactionFailed = false } }
            )) {
                Button("OK", role: .cancel) { viewModel.reactionFailed = false }
            } message: {
                Text(AppCopy.feedReactionFailed(appState.currentLanguage))
            }
        }
    }

    private var languageFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(FeedLanguageFilter.allCases) { filter in
                    let selected = viewModel.languageFilter == filter
                    Button {
                        viewModel.languageFilter = filter
                    } label: {
                        PillTag(
                            text: filter.pillLabel(appLanguage: appState.currentLanguage),
                            bgColor: selected ? AppColors.charcoal : AppColors.pureWhite,
                            textColor: selected ? AppColors.pureWhite : AppColors.charcoal,
                            isSelected: selected
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.sm)
        }
        .scrollClipDisabled()
        /// 外側の縦 `ScrollView` とのネストで高さが 0 になり白画面になるのを防ぐ。
        .frame(height: 52)
    }

    @ViewBuilder
    private var feedList: some View {
        let items = viewModel.visiblePosts(blockedUIDs: blockedUIDs)
        if items.isEmpty {
            Text(AppCopy.feedEmpty(appState.currentLanguage))
                .font(AppFonts.body(for: appState.currentLanguage, size: 15))
                .foregroundStyle(AppColors.greyText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xl)
        } else {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(items) { post in
                    FeedCardView(
                        post: post,
                        nickname: viewModel.nicknameByUID[post.uid],
                        relativeTime: relativeTimeString(for: post.createdAt),
                        currentUID: AuthService.currentUID,
                        reactionHighlight: viewModel.reactionHighlight(for: post, currentUID: AuthService.currentUID),
                        onReaction: { kind in
                            Task { await viewModel.react(to: post, kind: kind) }
                        },
                        onRequestBlock: {
                            blockConfirmUID = post.uid
                            if let n = viewModel.nicknameByUID[post.uid] {
                                blockConfirmName = AppCopy.feedBlockConfirmNamed(n.compactDisplayName, appState.currentLanguage)
                            } else {
                                blockConfirmName = AppCopy.feedBlockConfirmAnonymous(appState.currentLanguage)
                            }
                        },
                        onReport: { reason in
                            Task {
                                guard let reporter = AuthService.currentUID else { return }
                                await viewModel.submitReport(
                                    reporterUID: reporter,
                                    targetUID: post.uid,
                                    postID: post.documentID,
                                    reason: reason
                                )
                            }
                        }
                    )
                }
            }
        }
    }

    private func relativeTimeString(for date: Date?) -> String {
        guard let date else { return "—" }
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: appState.currentLanguage == .ja ? "ja_JP" : "en_US")
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    FeedView()
        .environmentObject(AppState())
        .modelContainer(for: [UserProfile.self, DrinkRecord.self], inMemory: true)
}
