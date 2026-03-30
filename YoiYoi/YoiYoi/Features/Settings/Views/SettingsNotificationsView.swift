import SwiftUI

/// 設定 > 通知: 飲酒記録リマインダーの ON/OFF と時刻。
struct SettingsNotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @State private var enabled: Bool = false
    @State private var time: Date = Calendar.current.date(
        bySettingHour: NotificationService.Settings.default.hour,
        minute: NotificationService.Settings.default.minute,
        second: 0,
        of: Date()
    ) ?? Date()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $enabled) {
                        Text(AppCopy.settingsNotificationsEnabled(appState.currentLanguage))
                    }
                    .tint(AppColors.coralRed)
                }

                Section {
                    DatePicker(
                        AppCopy.settingsNotificationsTime(appState.currentLanguage),
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!enabled)

                    Text(AppCopy.settingsNotificationsHint(appState.currentLanguage))
                        .font(AppFonts.sublabel(for: appState.currentLanguage, size: 12))
                        .foregroundStyle(AppColors.greyText)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, AppSpacing.sm)
                }
            }
            .navigationTitle(AppCopy.settingsNotificationsSection(appState.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppCopy.settingsCancel(appState.currentLanguage)) {
                        dismiss()
                    }
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
        .onAppear { load() }
    }

    private func load() {
        let s = NotificationService.currentSettings()
        enabled = s.enabled
        if let date = Calendar.current.date(bySettingHour: s.hour, minute: s.minute, second: 0, of: Date()) {
            time = date
        }
    }

    private func save() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let hour = comps.hour ?? NotificationService.Settings.default.hour
        let minute = comps.minute ?? NotificationService.Settings.default.minute
        NotificationService.update(enabled: enabled, hour: hour, minute: minute)
    }
}

#Preview {
    SettingsNotificationsView()
        .environmentObject(AppState())
}

