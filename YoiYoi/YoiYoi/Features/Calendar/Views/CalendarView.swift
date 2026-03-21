import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationStack {
            Text("カレンダー")
                .navigationTitle("📅 カレンダー")
        }
    }
}

#Preview {
    CalendarView()
}
