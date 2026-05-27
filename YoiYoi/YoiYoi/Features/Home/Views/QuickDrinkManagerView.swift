import SwiftData
import SwiftUI

struct QuickDrinkManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @Query(sort: \QuickDrinkPreset.sortOrder) private var presets: [QuickDrinkPreset]
    @State private var editingPreset: QuickDrinkPreset?

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(presets.enumerated()), id: \.element.id) { index, preset in
                    HStack {
                        presetLabel(for: preset)
                        Spacer()
                        Button {
                            editingPreset = preset
                        } label: {
                            Image(systemName: "pencil")
                        }
                        Button {
                            move(preset, by: -1)
                        } label: {
                            Image(systemName: "arrow.up")
                        }
                        .disabled(index == 0)
                        Button {
                            move(preset, by: 1)
                        } label: {
                            Image(systemName: "arrow.down")
                        }
                        .disabled(index == presets.count - 1)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle(AppCopy.homeFavorites(appState.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppCopy.drinkLogClose(appState.currentLanguage)) { dismiss() }
                }
            }
        }
        .sheet(item: $editingPreset) { preset in
            QuickDrinkPresetEditView(preset: preset)
                .environmentObject(appState)
        }
    }

    private func presetLabel(for preset: QuickDrinkPreset) -> some View {
        let type = DrinkType(rawValue: preset.drinkType)
        return HStack(spacing: AppSpacing.sm) {
            SVGIcon(icon: type?.icon ?? .drinkBeer, size: 18, color: AppColors.coralRed)
            Text("\(type?.shortLabel(for: appState.currentLanguage) ?? preset.displayName) \(Int(preset.volumeML))ml ×\(preset.numberOfDrinks)")
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { presets[$0] }.forEach(modelContext.delete)
        normalizeOrders()
        try? modelContext.save()
        NotificationCenter.default.post(name: .drinkLogSheetDismissed, object: nil)
    }

    private func move(_ preset: QuickDrinkPreset, by delta: Int) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        let target = index + delta
        guard presets.indices.contains(target) else { return }
        let other = presets[target]
        swap(&preset.sortOrder, &other.sortOrder)
        try? modelContext.save()
    }

    private func normalizeOrders() {
        for (index, preset) in presets.enumerated() {
            preset.sortOrder = index
        }
    }
}

private struct QuickDrinkPresetEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    let preset: QuickDrinkPreset

    @State private var type: DrinkType = .beer
    @State private var abvPercent: Double = 5
    @State private var drinks = 1

    var body: some View {
        NavigationStack {
            Form {
                Picker(AppCopy.drinkLogTitle(appState.currentLanguage), selection: $type) {
                    ForEach(DrinkType.allCases, id: \.self) { option in
                        Text(option.shortLabel(for: appState.currentLanguage)).tag(option)
                    }
                }
                Stepper(
                    "\(AppCopy.drinkLogAbv(appState.currentLanguage)): \(abvPercent, specifier: "%.1f")",
                    value: $abvPercent,
                    in: 0...100,
                    step: 0.5
                )
                Stepper(
                    "\(AppCopy.drinkLogDrinksCount(appState.currentLanguage)): \(drinks)",
                    value: $drinks,
                    in: 1...99
                )
            }
            .navigationTitle(AppCopy.homeFavorites(appState.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppCopy.settingsCancel(appState.currentLanguage)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppCopy.settingsSave(appState.currentLanguage)) {
                        preset.displayName = type.rawValue
                        preset.drinkType = type.rawValue
                        preset.volumeML = type.defaultVolumeML
                        preset.abvFraction = AlcoholByVolume.fromPercentage(abvPercent).fraction
                        preset.numberOfDrinks = drinks
                        try? modelContext.save()
                        NotificationCenter.default.post(name: .drinkLogSheetDismissed, object: nil)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            type = DrinkType(rawValue: preset.drinkType) ?? .beer
            abvPercent = AlcoholByVolume.fromFraction(preset.abvFraction).percentage
            drinks = preset.numberOfDrinks
        }
    }
}
