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
                Section {
                    Text(AppCopy.settingsCoachIntro(appState.currentLanguage))
                        .font(AppFonts.body(for: appState.currentLanguage, size: 13))
                        .foregroundStyle(AppColors.greyText)
                        .listRowBackground(AppColors.surfaceElevated)

                    ForEach(CoachPersonality.allCases) { option in
                        Button {
                            personality = option
                        } label: {
                            coachModeRow(option)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(AppColors.surfaceElevated)
                    }
                } header: {
                    Text(AppCopy.settingsCoachPersonality(appState.currentLanguage))
                        .font(.caption)
                        .foregroundStyle(AppColors.greyText)
                        .textCase(nil)
                }

                Section {
                    Picker(AppCopy.settingsHydrationInterval(appState.currentLanguage), selection: $hydrationIntervalMinutes) {
                        ForEach(intervals, id: \.self) { minutes in
                            Text(AppCopy.settingsMinutes(minutes, appState.currentLanguage)).tag(minutes)
                        }
                    }
                    .listRowBackground(AppColors.surfaceElevated)
                    Toggle(AppCopy.settingsLastOrderReminder(appState.currentLanguage), isOn: $lastOrderReminderEnabled)
                        .listRowBackground(AppColors.surfaceElevated)
                } header: {
                    Text(AppCopy.settingsCoachSupportSection(appState.currentLanguage))
                        .font(.caption)
                        .foregroundStyle(AppColors.greyText)
                        .textCase(nil)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.cream)
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

    private func coachModeRow(_ option: CoachPersonality) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            SVGIcon(icon: option.icon, size: 22, color: option == personality ? AppColors.coralRed : AppColors.greyText)
                .frame(width: 30, height: 30)
                .background((option == personality ? AppColors.coralRed : AppColors.mintLight).opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: AppSpacing.xs) {
                    Text(option.displayName(appState.currentLanguage))
                        .font(AppFonts.body(for: appState.currentLanguage, size: 15).weight(.semibold))
                        .foregroundStyle(AppColors.charcoal)
                    if option == .friendly {
                        Text(appState.currentLanguage == .ja ? "標準" : "Default")
                            .font(AppFonts.sublabel(for: appState.currentLanguage, size: 10))
                            .foregroundStyle(AppColors.coralRed)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(AppColors.coralRed.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }

                Text(option.description(appState.currentLanguage))
                    .font(AppFonts.sublabel(for: appState.currentLanguage, size: 12))
                    .foregroundStyle(AppColors.greyText)

                Text("\(AppCopy.settingsCoachSampleLabel(appState.currentLanguage)): \(option.sampleMessage(appState.currentLanguage))")
                    .font(AppFonts.sublabel(for: appState.currentLanguage, size: 11))
                    .foregroundStyle(AppColors.greyText.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AppSpacing.sm)

            Image(systemName: option == personality ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(option == personality ? AppColors.coralRed : AppColors.greyText.opacity(0.4))
                .padding(.top, 2)
        }
        .padding(.vertical, AppSpacing.xs)
        .contentShape(Rectangle())
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
