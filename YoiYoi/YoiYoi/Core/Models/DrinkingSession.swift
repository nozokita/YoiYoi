import Foundation
import SwiftData

@Model
final class DrinkingSession {
    @Attribute(.unique) var id: UUID = UUID()
    var startTime: Date
    var endTime: Date?
    var hydrationCount: Int = 0
    var preventedLastOrder: Bool = false

    var isActive: Bool { endTime == nil }

    init(startTime: Date = Date()) {
        self.startTime = startTime
    }
}
