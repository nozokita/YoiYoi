import SwiftData
import SwiftUI

struct CoachSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var personality: CoachPersonality = .friendly
    @State private var hydrationIntervalMinutes = 30
    @State private var lastOrderReminderEnabled = true

    private let intervals = [15, 30, 45, 60]

    var body: some View {
        NavigationStack {
            Form {
                Section(AppCopy.settingsCoachPersonality(appState.currentLanguage)) {
                    Picker(AppCopy.settingsCoachPersonality(appState.currentLanguage), selection: $personality) {
                        ForEach(CoachPersonality.allCases) { option in
                            Text("\(option.emoji) \(option.displayName(appState.currentLanguage))").tag(option)
                        }
                    }
                    Text(personality.sampleMessage(appState.currentLanguage))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Picker(AppCopy.settingsHydrationInterval(appState.currentLanguage), selection: $hydrationIntervalMinutes) {
                        ForEach(intervals, id: \.self) { minutes in
                            Text(AppCopy.settingsMinutes(minutes, appState.currentLanguage)).tag(minutes)
                        }
                    }
                    Toggle(AppCopy.settingsLastOrderReminder(appState.currentLanguage), isOn: $lastOrderReminderEnabled)
                }
            }
            .navigationTitle(AppCopy.settingsCoachTitle(appState.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppCopy.settingsCancel(appState.currentLanguage)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppCopy.settingsSave(appState.currentLanguage)) {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let profile = try? modelContext.fetch(FetchDescriptor<UserProfile>()).first else { return }
        personality = CoachPersonality(rawValue: profile.aiCoachPersonality) ?? .friendly
        hydrationIntervalMinutes = profile.hydrationIntervalMinutes
        lastOrderReminderEnabled = profile.lastOrderReminderEnabled
    }

    private func save() {
        guard let profile = try? modelContext.fetch(FetchDescriptor<UserProfile>()).first else { return }
        profile.aiCoachPersonality = personality.rawValue
        profile.hydrationIntervalMinutes = hydrationIntervalMinutes
        profile.lastOrderReminderEnabled = lastOrderReminderEnabled
        try? modelContext.save()
        NotificationCenter.default.post(name: .userProfileDidChange, object: nil)
    }
}

#Preview {
    CoachSettingsView()
        .environmentObject(AppState())
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
