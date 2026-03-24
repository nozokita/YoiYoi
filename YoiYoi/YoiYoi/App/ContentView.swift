import SwiftUI

extension Notification.Name {
    /// 記録シートを閉じたあとホーム等が SwiftData を取り直すためのフック（Phase 6 保存後も利用）。
    static let drinkLogSheetDismissed = Notification.Name("YoiYoi.drinkLogSheetDismissed")
}

/// **段階実装** — 1 ステップずつ足す。
/// - step1: クリーム + カウンタ
/// - step2: 下の「タブ風」2択（`TabView` は使わない）
/// - step3: タブ1に `NavigationStack` + リスト → 詳細（データは固定文字列のみ）
/// - step4: タブ0から `.sheet` でモーダル（中身はプレースホルダー）
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var tapCount = 0
    @State private var showPlaceholderSheet = false

    private let otherTabSampleTitles = ["項目 A", "項目 B", "項目 C"]

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case 0:
                    stepOnePanel
                case 1:
                    tabTwoPlaceholder
                default:
                    stepOnePanel
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .background(AppColors.greyText.opacity(0.25))

            bottomBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
        .sheet(isPresented: $showPlaceholderSheet, onDismiss: {
            NotificationCenter.default.post(name: .drinkLogSheetDismissed, object: nil)
        }) {
            placeholderSheet
        }
        .onAppear {
            AppLaunchDiagnostics.log("ContentView.onAppear（段階実装 step4: sheet placeholder） selectedTab=\(selectedTab)")
        }
    }

    private var placeholderSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("モーダル（プレースホルダー）")
                    .font(.headline)
                    .foregroundStyle(AppColors.charcoal)
                Text("次の段階で飲酒記録などのフォームをここに載せる")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.greyText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.cream)
            .navigationTitle("例: 記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        showPlaceholderSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    /// step1 の内容（そのまま残す）
    private var stepOnePanel: some View {
        VStack(spacing: 24) {
            Text("YoiYoi")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.charcoal)

            Text("HELLO WORLD")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.coralRed)

            Text("ステップ4: 「シートを開く」でモーダル。「その他」でリスト→詳細。")
                .font(.subheadline)
                .foregroundStyle(AppColors.greyText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showPlaceholderSheet = true
            } label: {
                Text("シートを開く（プレースホルダー）")
                    .font(.headline)
                    .foregroundStyle(AppColors.coralRed)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppColors.coralLight.opacity(0.35), in: Capsule())
            }
            .buttonStyle(.plain)

            Button {
                tapCount += 1
            } label: {
                Text("タップした回数: \(tapCount)")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(AppColors.coralRed, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// タブ1: ナビゲーションの動作確認（中身はダミー行だけ）
    private var tabTwoPlaceholder: some View {
        NavigationStack {
            List {
                ForEach(otherTabSampleTitles, id: \.self) { title in
                    NavigationLink {
                        otherDetailPlaceholder(title: title)
                    } label: {
                        Text(title)
                            .foregroundStyle(AppColors.charcoal)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColors.cream)
            .navigationTitle("その他")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func otherDetailPlaceholder(title: String) -> some View {
        VStack(spacing: 16) {
            Text("詳細（プレースホルダー）")
                .font(.headline)
                .foregroundStyle(AppColors.charcoal)
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(AppColors.coralRed)
            Text("次の段階でここに実データや編集 UI を載せる")
                .font(.subheadline)
                .foregroundStyle(AppColors.greyText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            barItem(index: 0, title: "ホーム", systemImage: "house.fill")
            barItem(index: 1, title: "その他", systemImage: "circle.grid.2x2.fill")
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(AppColors.cream)
    }

    private func barItem(index: Int, title: String, systemImage: String) -> some View {
        let on = selectedTab == index
        return Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: on ? .semibold : .regular))
                Text(title)
                    .font(.system(size: 11, weight: on ? .semibold : .regular))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(on ? AppColors.coralRed : AppColors.greyText)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
