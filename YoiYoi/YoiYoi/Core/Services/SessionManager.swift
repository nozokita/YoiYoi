import Foundation
import SwiftData

enum SessionManager {
    static func activeSession(in sessions: [DrinkingSession]) -> DrinkingSession? {
        sessions
            .filter(\.isActive)
            .sorted { $0.startTime > $1.startTime }
            .first
    }

    static func records(for sessionID: UUID, in records: [DrinkRecord]) -> [DrinkRecord] {
        records.filter { $0.sessionID == sessionID }
    }

    static func pureAlcoholTotal(for sessionID: UUID, in allRecords: [DrinkRecord]) -> Double {
        records(for: sessionID, in: allRecords).reduce(0) { $0 + $1.pureAlcoholGrams }
    }

    static func elapsedText(from start: Date, to end: Date = Date()) -> String {
        let seconds = max(Int(end.timeIntervalSince(start)), 0)
        return String(format: "%02d:%02d:%02d", seconds / 3600, (seconds / 60) % 60, seconds % 60)
    }
}
