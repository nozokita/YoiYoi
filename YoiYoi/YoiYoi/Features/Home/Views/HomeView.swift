import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            Text("ホーム")
                .navigationTitle("🏠 ホーム")
        }
    }
}

#Preview {
    HomeView()
}
