import SwiftData
import SwiftUI

/// 飲酒記録を CSV で書き出し、共有シートで送れるようにする。
struct SettingsDataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var exportURL: URL?
    @State private var exportError: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text(AppCopy.settingsExportExplanation(appState.currentLanguage))
                    .font(AppFonts.body(for: appState.currentLanguage, size: 15))
                    .foregroundStyle(AppColors.greyText)
                    .fixedSize(horizontal: false, vertical: true)

                if let exportURL {
                    ShareLink(
                        item: exportURL,
                        subject: Text(AppCopy.settingsExportShareSubject(appState.currentLanguage)),
                        message: Text(AppCopy.settingsExportShareMessage(appState.currentLanguage))
                    ) {
                        Label(AppCopy.settingsExportShareButton(appState.currentLanguage), systemImage: "square.and.arrow.up")
                            .font(AppFonts.body(for: appState.currentLanguage, size: 17))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(AppColors.coralRed)
                            .foregroundStyle(AppColors.pureWhite)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    Text(AppCopy.settingsExportShareHint(appState.currentLanguage))
                        .font(AppFonts.sublabel(for: appState.currentLanguage, size: 12))
                        .foregroundStyle(AppColors.greyText)
                } else if let exportError {
                    Text(exportError)
                        .font(AppFonts.body(for: appState.currentLanguage, size: 14))
                        .foregroundStyle(AppColors.warmCoral)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppColors.cream)
            .navigationTitle(AppCopy.settingsExportTitle(appState.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppCopy.settingsCancel(appState.currentLanguage)) {
                        if let exportURL {
                            try? FileManager.default.removeItem(at: exportURL)
                        }
                        dismiss()
                    }
                }
            }
            .task {
                await generateExport()
            }
        }
    }

    @MainActor
    private func generateExport() async {
        exportError = nil
        do {
            let url = try DataExportService.exportDrinkRecordsCSV(modelContext: modelContext)
            exportURL = url
        } catch {
            exportError = AppCopy.settingsExportFailed(appState.currentLanguage)
        }
    }
}

#Preview {
    SettingsDataExportView()
        .environmentObject(AppState())
        .modelContainer(for: [DrinkRecord.self, UserProfile.self], inMemory: true)
}
