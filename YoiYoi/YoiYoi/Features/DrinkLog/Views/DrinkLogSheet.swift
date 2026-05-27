import SwiftData
import SwiftUI

/// DESIGN.md「飲酒記録シート」— グリッド・調整カード・純アルコール量のローカル保存。
struct DrinkLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @Query(sort: \QuickDrinkPreset.sortOrder) private var presets: [QuickDrinkPreset]
    @Query(sort: \DrinkRecord.loggedAt, order: .reverse) private var records: [DrinkRecord]

    @State private var viewModel = DrinkLogViewModel()
    @State private var saveError: String?
    var sessionID: UUID?

    private var recentRecords: [DrinkRecord] {
        QuickDrinkService.recentUnique(from: records)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text(AppCopy.drinkLogTitle(appState.currentLanguage))
                        .font(AppFonts.screenTitle())
                        .foregroundStyle(AppColors.charcoal)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        DrinkGridView(selection: $viewModel.selectedType, onSelect: viewModel.select)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.pureWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .themedShadow(themeColor: AppColors.coralRed, opacity: 0.10, radius: 16, y: 6)

                    reusableSelections
                    adjustmentCard

                    if viewModel.canSave {
                        Button(AppCopy.drinkLogAddFavorite(appState.currentLanguage)) {
                            addFavorite()
                        }
                        .font(AppFonts.body(for: appState.currentLanguage, size: 15))
                        .foregroundStyle(AppColors.coralRed)
                        .frame(maxWidth: .infinity)
                    }

                    PuffyButton(title: AppCopy.drinkLogSave(appState.currentLanguage), isEnabled: viewModel.canSave) {
                        saveRecord()
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(
                LinearGradient(
                    colors: [AppColors.pureWhite, AppColors.cream],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppCopy.drinkLogClose(appState.currentLanguage)) { dismiss() }
                }
            }
        }
        .alert(AppCopy.drinkLogSaveFailed(appState.currentLanguage), isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveError ?? "")
        }
    }

    @ViewBuilder
    private var reusableSelections: some View {
        if !presets.isEmpty || !recentRecords.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                if !presets.isEmpty {
                    selectionRow(title: AppCopy.homeFavorites(appState.currentLanguage), records: nil)
                }
                if !recentRecords.isEmpty {
                    selectionRow(title: AppCopy.homeRecent(appState.currentLanguage), records: recentRecords)
                }
            }
            .padding(AppSpacing.lg)
            .contentCard(themeColor: AppColors.yellowLight)
        }
    }

    private func selectionRow(title: String, records: [DrinkRecord]?) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFonts.sublabel(for: appState.currentLanguage, size: 13))
                .foregroundStyle(AppColors.greyText)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    if let records {
                        ForEach(records, id: \.id) { record in
                            reusableButton(
                                type: record.drinkType,
                                volume: record.volumeML,
                                abv: record.abvFraction,
                                drinks: record.numberOfDrinks
                            )
                        }
                    } else {
                        ForEach(presets, id: \.id) { preset in
                            reusableButton(
                                type: preset.drinkType,
                                volume: preset.volumeML,
                                abv: preset.abvFraction,
                                drinks: preset.numberOfDrinks
                            )
                        }
                    }
                }
            }
        }
    }

    private func reusableButton(type: String, volume: Double, abv: Double, drinks: Int) -> some View {
        let drinkType = DrinkType(rawValue: type)
        let name = DrinkType.shortLabel(forRawType: type, language: appState.currentLanguage)
        return Button {
            viewModel.apply(drinkType: type, volumeML: volume, abvFraction: abv, numberOfDrinks: drinks)
        } label: {
            HStack(spacing: AppSpacing.xs) {
                SVGIcon(icon: drinkType?.icon ?? .drinkBeer, size: 16, color: AppColors.coralRed)
                Text("\(name) \(Int(volume))ml ×\(drinks)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.charcoal)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColors.pureWhite)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var adjustmentCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(AppCopy.drinkLogAdjust(appState.currentLanguage))
                .font(AppFonts.cardTitle())
                .foregroundStyle(AppColors.charcoal)

            stepperRow(title: AppCopy.drinkLogDrinksCount(appState.currentLanguage), value: "\(viewModel.numberOfDrinks)", decrement: viewModel.decrementDrinks, increment: viewModel.incrementDrinks)

            stepperRow(
                title: AppCopy.drinkLogAbv(appState.currentLanguage),
                value: String(format: "%.1f", viewModel.abvPercent),
                decrement: viewModel.decrementAbv,
                increment: viewModel.incrementAbv
            )

            Divider().background(AppColors.greyText.opacity(0.25))

            VStack(spacing: AppSpacing.xs) {
                Text(AppCopy.drinkLogPureAlcohol(appState.currentLanguage))
                    .font(AppFonts.sublabel(for: appState.currentLanguage, size: 13))
                    .foregroundStyle(AppColors.greyText)
                Text(String(format: "%.1fg", viewModel.pureAlcoholGrams))
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColors.coralRed)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentCard(themeColor: AppColors.coralRed)
    }

    private func stepperRow(title: String, value: String, decrement: @escaping () -> Void, increment: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(AppFonts.body(for: appState.currentLanguage, size: 16))
                .foregroundStyle(AppColors.charcoal)
            Spacer()
            Button("－", action: decrement)
                .font(.title3.bold())
                .foregroundStyle(AppColors.coralRed)
                .frame(minWidth: 44, minHeight: 44)
            Text(value)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColors.charcoal)
                .frame(minWidth: 52)
            Button("＋", action: increment)
                .font(.title3.bold())
                .foregroundStyle(AppColors.coralRed)
                .frame(minWidth: 44, minHeight: 44)
        }
    }

    private func saveRecord() {
        guard let type = viewModel.selectedType else { return }
        do {
            let record = DrinkRecord(
                drinkType: type.rawValue,
                volumeML: viewModel.volumeML,
                abv: viewModel.abv,
                numberOfDrinks: viewModel.numberOfDrinks,
                sessionID: sessionID
            )
            modelContext.insert(record)
            try modelContext.save()

            // `dismiss` と親の `onDismiss`→`reloadFromStore` が同一トランジション内で走るとメインスレッドが詰まることがあるため、次フレームにずらす。
            DispatchQueue.main.async {
                dismiss()
            }
        } catch {
            saveError = error.localizedDescription
        }
    }

    private func addFavorite() {
        guard let type = viewModel.selectedType else { return }
        if presets.count >= QuickDrinkPreset.maximumCount {
            saveError = AppCopy.drinkLogFavoritesLimit(appState.currentLanguage)
            return
        }
        let duplicate = presets.contains {
            $0.drinkType == type.rawValue
                && $0.volumeML == viewModel.volumeML
                && $0.abvFraction == viewModel.abv.fraction
                && $0.numberOfDrinks == viewModel.numberOfDrinks
        }
        guard !duplicate else { return }
        modelContext.insert(
            QuickDrinkPreset(
                displayName: type.rawValue,
                drinkType: type.rawValue,
                volumeML: viewModel.volumeML,
                abvFraction: viewModel.abv.fraction,
                numberOfDrinks: viewModel.numberOfDrinks,
                sortOrder: presets.count
            )
        )
        do {
            try modelContext.save()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#Preview {
    DrinkLogSheet()
        .environmentObject(AppState())
        .modelContainer(for: [DrinkRecord.self, UserProfile.self, DrinkingSession.self, QuickDrinkPreset.self], inMemory: true)
}
