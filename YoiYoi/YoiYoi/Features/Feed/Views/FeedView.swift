import SwiftUI

/// `FeatureFlags.isFeedEnabled == false` のときはタブごと非表示（ContentView）。
struct FeedView: View {
    var body: some View {
        NavigationStack {
            Text("みんなの記録")
                .navigationTitle("みんな")
        }
    }
}

#Preview {
    FeedView()
}
