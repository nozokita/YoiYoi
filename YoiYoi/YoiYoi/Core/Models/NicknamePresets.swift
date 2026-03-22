import Foundation

/// `Resources/NicknameData/*.json` を読み込む。バンドルにファイルが無い場合はエラー。
enum NicknamePresets {
    enum LoadError: Error {
        case fileNotFound(String)
        case decodingFailed(String, Error)
    }

    private static let subdirectory = "NicknameData"

    private static func data(named name: String, bundle: Bundle) throws -> Data {
        let base = name.replacingOccurrences(of: ".json", with: "")
        guard let url = bundle.url(forResource: base, withExtension: "json", subdirectory: subdirectory)
            ?? bundle.url(forResource: base, withExtension: "json")
        else {
            throw LoadError.fileNotFound(name)
        }
        return try Data(contentsOf: url)
    }

    static func loadStringArray(named fileName: String, bundle: Bundle = .main) throws -> [String] {
        let data = try data(named: fileName, bundle: bundle)
        do {
            return try JSONDecoder().decode([String].self, from: data)
        } catch {
            throw LoadError.decodingFailed(fileName, error)
        }
    }

    static func adjectives(for language: SupportedLanguage, bundle: Bundle = .main) throws -> [String] {
        try loadStringArray(named: "adjectives_\(language.rawValue)", bundle: bundle)
    }

    static func nouns(for language: SupportedLanguage, bundle: Bundle = .main) throws -> [String] {
        try loadStringArray(named: "nouns_\(language.rawValue)", bundle: bundle)
    }

    static func flags(bundle: Bundle = .main) throws -> [String] {
        try loadStringArray(named: "flags", bundle: bundle)
    }

    static func emojis(bundle: Bundle = .main) throws -> [String] {
        try loadStringArray(named: "emojis", bundle: bundle)
    }
}
