import Foundation
import SwiftUI
import Testing
@testable import DesignSystem

@Suite("書体の受け取り口")
struct BrandTypefaceTests {

    @Test("書体を渡さないアプリの font は Typography の定義から変わらない")
    func systemFontMatchesTypography() {
        // ⚠️ ここがずれると、書体を指定していないアプリの見た目が黙って変わる。
        #expect(TypeRole.screenTitle.systemFont == .screenTitle)
        #expect(TypeRole.sectionTitle.systemFont == .sectionTitle)
        #expect(TypeRole.itemTitle.systemFont == .itemTitle)
        // ⚠️ `.body` / `.caption` は SwiftUI 側の同名メンバと衝突して書けないため、
        // 定義そのもの (Typography.swift) と同じ値を書いて突き合わせる。
        #expect(TypeRole.body.systemFont == .system(.body))
        #expect(TypeRole.caption.systemFont == .footnote)
        #expect(TypeRole.actionLabel.systemFont == .actionLabel)
    }

    @Test("書体が無いときは OS のテキストスタイルをそのまま使う")
    func nilTypefaceFallsBackToSystem() {
        for role in TypeRole.allCases {
            #expect(role.font(typeface: nil) == role.systemFont)
            // 空文字は「指定なし」と同じ扱い。名前として解決できないため
            #expect(role.font(typeface: "") == role.systemFont)
        }
    }

    @Test("書体を渡すと役割ごとに別の font になる")
    func namedTypefaceReplacesFont() {
        for role in TypeRole.allCases {
            #expect(role.font(typeface: "HiraMaruProN-W4") != role.systemFont)
        }
        // 役割が違えば font も違う (同じ大きさへ丸め込まない)
        #expect(TypeRole.screenTitle.font(typeface: "HiraMaruProN-W4")
                != TypeRole.body.font(typeface: "HiraMaruProN-W4"))
    }

    @Test("Dynamic Type の基準を必ず渡す")
    func customFontKeepsDynamicType() throws {
        // Font の値からは relativeTo を読み出せないため、実装の形で確かめる。
        // ⚠️ Font.custom(_:size:) だけだと、設定アプリで文字を大きくしても追随しない。
        let source = try Self.source(named: "Tokens/BrandTypeface.swift")
        #expect(source.contains("relativeTo: m.textStyle"))
        #expect(source.contains(".custom(typeface, size: m.size)") == false)
    }

    @Test("共有スタイルは環境から書体を読む口を通す")
    func sharedStylesUseBrandFont() throws {
        // .font(.actionLabel) のままだと、アプリが渡した書体がボタンに効かない。
        let button = try Self.source(named: "Styles/ButtonStyles.swift")
        #expect(button.contains(".brandFont(.actionLabel)"))
        #expect(button.contains(".font(.actionLabel)") == false)

        let panel = try Self.source(named: "Styles/PanelModifiers.swift")
        #expect(panel.contains(".brandFont(.caption)"))
        #expect(panel.contains(".font(.caption)") == false)
    }

    private static func source(named path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // DesignSystemTests
            .deletingLastPathComponent()   // Tests
            .deletingLastPathComponent()   // package root
        let url = root.appending(path: "Sources/DesignSystem/\(path)")
        return try String(contentsOf: url, encoding: .utf8)
    }
}
