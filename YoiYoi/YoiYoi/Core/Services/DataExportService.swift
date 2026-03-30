import Foundation
import SwiftData

/// ローカル SwiftData の飲酒記録を CSV にまとめ、一時ファイル URL を返す。
enum DataExportService {
    enum ExportError: Error {
        case writeFailed
    }

    static func exportDrinkRecordsCSV(modelContext: ModelContext) throws -> URL {
        let desc = FetchDescriptor<DrinkRecord>(
            sortBy: [SortDescriptor(\.loggedAt, order: .reverse)]
        )
        let records = try modelContext.fetch(desc)

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]

        var lines: [String] = []
        lines.append("id,drink_type,volume_ml,abv_fraction,pure_alcohol_g,number_of_drinks,logged_at")
        for r in records {
            let escapedType = escapeCSVField(r.drinkType)
            let row = "\(r.id.uuidString),\(escapedType),\(r.volumeML),\(r.abvFraction),\(r.pureAlcoholGrams),\(r.numberOfDrinks),\(iso.string(from: r.loggedAt))"
            lines.append(row)
        }

        let csv = lines.joined(separator: "\n")
        let name = "yoi-yoi-drinks-\(Int(Date().timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            throw ExportError.writeFailed
        }
    }

    private static func escapeCSVField(_ raw: String) -> String {
        if raw.contains(",") || raw.contains("\"") || raw.contains("\n") {
            let doubled = raw.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(doubled)\""
        }
        return raw
    }
}
