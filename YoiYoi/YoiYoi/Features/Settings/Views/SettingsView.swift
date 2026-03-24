import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("設定")
                .navigationTitle("⚙️ 設定")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.cream)
    }
}

#Preview {
    SettingsView()
}
