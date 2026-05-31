import Foundation
import SwiftData

enum TelemetryService {
    /// Local-only telemetry for product-quality analysis. Events are never uploaded by this service.
    static func track(
        _ name: EventName,
        screen: Screen? = nil,
        attributes: [String: String] = [:],
        modelContext: ModelContext
    ) {
        let event = TelemetryEvent(
            name: name.rawValue,
            screen: screen?.rawValue,
            attributesJSON: encode(attributes)
        )
        modelContext.insert(event)
        try? modelContext.save()
        pruneIfNeeded(modelContext: modelContext)
    }

    static func gramsBand(_ grams: Double) -> String {
        switch grams {
        case ..<1:
            return "0"
        case ..<10:
            return "1_9"
        case ..<20:
            return "10_19"
        case ..<40:
            return "20_39"
        case ..<60:
            return "40_59"
        default:
            return "60_plus"
        }
    }

    static func ratioBand(consumed: Double, goal: Double) -> String {
        guard goal > 0 else { return "no_goal" }
        switch consumed / goal {
        case ..<0.4:
            return "under_40"
        case ..<0.8:
            return "40_79"
        case ..<1.0:
            return "80_99"
        case ..<1.2:
            return "100_119"
        default:
            return "120_plus"
        }
    }

    private static func encode(_ attributes: [String: String]) -> String {
        guard JSONSerialization.isValidJSONObject(attributes),
              let data = try? JSONSerialization.data(withJSONObject: attributes, options: [.sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    private static func pruneIfNeeded(modelContext: ModelContext, limit: Int = 1_000) {
        var descriptor = FetchDescriptor<TelemetryEvent>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit + 50
        guard let events = try? modelContext.fetch(descriptor), events.count > limit else { return }
        for event in events.dropFirst(limit) {
            modelContext.delete(event)
        }
        try? modelContext.save()
    }
}

extension TelemetryService {
    enum EventName: String {
        case screenViewed = "screen_viewed"
        case tabSelected = "tab_selected"
        case fabTapped = "fab_tapped"
        case drinkLogOpened = "drink_log_opened"
        case drinkLogSaved = "drink_log_saved"
        case drinkLogDeleted = "drink_log_deleted"
        case quickRecordSaved = "quick_record_saved"
        case quickRecordUndone = "quick_record_undone"
        case aiCommentRendered = "ai_comment_rendered"
        case aiCommentRefreshed = "ai_comment_refreshed"
        case aiCommentStyleSaved = "ai_comment_style_saved"
        case sessionStarted = "session_started"
        case sessionOpened = "session_opened"
    }

    enum Screen: String {
        case home
        case calendar
        case settings
        case drinkLog
        case aiCommentSettings
        case activeSession
    }
}
