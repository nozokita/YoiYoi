import Foundation
import SwiftData

@Model
final class TelemetryEvent {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var screen: String?
    var attributesJSON: String
    var createdAt: Date

    init(
        name: String,
        screen: String? = nil,
        attributesJSON: String = "{}",
        createdAt: Date = Date()
    ) {
        self.name = name
        self.screen = screen
        self.attributesJSON = attributesJSON
        self.createdAt = createdAt
    }
}
