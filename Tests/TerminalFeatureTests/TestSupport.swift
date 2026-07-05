import Foundation
import AinkradAppKit
@testable import TerminalFeature

/// Builds a `HostThemeTokens` snapshot with the given theme id. Match-Theme
/// resolution reads only `tokens.themeID`, so the color values are irrelevant
/// to these assertions — black stands in for all of them.
func tokens(themeID: String) -> HostThemeTokens {
    HostThemeTokens(themeID: themeID, background: .black, surface: .black, surfaceElevated: .black,
                    accentPrimary: .black, accentSecondary: .black, accentTertiary: .black, foreground: .black)
}

/// Test-only documents: `Codable` values keyed by a stable `documentID`.
protocol TestDocument: Codable {
    static var documentID: String { get }
}

extension TerminalSettings: TestDocument {}

/// An in-memory persistence store used by the moved settings tests. Encodes on
/// save and decodes on load, exercising the same `Codable` path as disk.
final class InMemoryPersistenceStore {
    private var storage: [String: Data] = [:]

    func load<T: TestDocument>(_ type: T.Type) -> T? {
        guard let data = storage[T.documentID] else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func save<T: TestDocument>(_ document: T) {
        guard let data = try? JSONEncoder().encode(document) else { return }
        storage[T.documentID] = data
    }

    func delete<T: TestDocument>(_ type: T.Type) {
        storage[T.documentID] = nil
    }
}
