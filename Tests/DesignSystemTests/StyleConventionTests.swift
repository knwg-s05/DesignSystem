import Foundation
import Testing

@Suite("スタイル規約")
struct StyleConventionTests {

    @Test("statusBadgeは既定色をbrandTintから読み、文字色にtintを使わない")
    func statusBadgeUsesBrandTintAndReadableTextColor() throws {
        let source = try Self.source(named: "PanelModifiers.swift")

        #expect(source.contains(#"@Environment(\.brandTint)"#))
        #expect(source.contains("private let tint: Color?"))
        #expect(source.contains("public init(tint: Color? = nil)"))
        #expect(source.contains("let resolvedTint = tint ?? brandTint"))
        #expect(source.contains(".foregroundStyle(.contentPrimary)"))
        #expect(source.contains("tint: Color = .brandAccent") == false)
    }

    @Test("hudPanelの枠線はAnimalGarden側で使っていた強さを保つ")
    func hudPanelKeepsReadableBorder() throws {
        let source = try Self.source(named: "PanelModifiers.swift")

        #expect(source.contains(".stroke(Color.contentPrimary.opacity(0.2), lineWidth: 1)"))
        #expect(source.contains(".stroke(Color.contentPrimary.opacity(0.16), lineWidth: 1)") == false)
    }

    private static func source(named fileName: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = packageRoot
            .appending(path: "Sources/DesignSystem/Styles")
            .appending(path: fileName)

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
