import SwiftData
import SwiftUI

@main
struct YoiYoiApp: App {
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DrinkRecord.self,
            UserProfile.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        FirebaseBootstrap.configureIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.onboardingCompleted {
                    ContentView()
                } else {
                    OnboardingContainerView()
                }
            }
            .environment(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}
