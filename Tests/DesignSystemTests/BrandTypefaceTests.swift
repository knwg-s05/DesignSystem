import Foundation
import SwiftUI
import Testing
@testable import DesignSystem

@Suite("書体の受け取り口")
struct BrandTypefaceTests {

    @Test("公開している font の値が変わっていない")
    func publicFontsKeepTheirValues() {
        // ⚠️ **静的メンバどうしを突き合わせない。**`TypeRole.screenTitle.systemFont == .screenTitle`
        // のように書くと、両辺が同じ出どころを見るため**何を変えても落ちない試験**になる。
        // ここは OS のテキストスタイルから組んだ値を直接書き、見え方が変わったら落ちるようにする。
        #expect(Font.screenTitle == .system(.largeTitle).weight(.bold))
        #expect(Font.sectionTitle == .system(.title3).weight(.semibold))
        #expect(Font.itemTitle == .system(.headline))
        // ⚠️ `.body` / `.caption` は SwiftUI 側の同名メンバと衝突して `Font.body` と書けないため、
        // 役割から引く (右辺が実体なので、値が動けば落ちることは変わらない)
        #expect(TypeRole.body.systemFont == .system(.body))
        #expect(TypeRole.caption.systemFont == .system(.footnote))
        #expect(Font.actionLabel == .system(.body).weight(.semibold))

        // 公開している名前と役割の対応 (どちらも同じ出どころなので、対応の確認にしかならない)
        for role in TypeRole.allCases {
            #expect(role.systemFont == role.font(typeface: nil))
        }
    }

    @Test("名前付き書体の基準は役割ごとに決まっている")
    func metricsAreFixed() {
        // 名前付き書体は `metrics` から組む。**値が動いたら落ちるように直接書く。**
        // ⚠️ `weight` の `nil` は「テキストスタイルの既定のまま」。`headline` は既定で太いため、
        // `.semibold` を重ねると別の値になる (`公開している font の値が変わっていない` が捕まえる)。
        let expected: [TypeRole: (CGFloat, Font.TextStyle, Font.Weight?)] = [
            .screenTitle: (34, .largeTitle, .bold),
            .sectionTitle: (20, .title3, .semibold),
            .itemTitle: (17, .headline, nil),
            .body: (17, .body, nil),
            .caption: (13, .footnote, nil),
            .actionLabel: (17, .body, .semibold),
        ]

        // 役割を足したら、ここへも足す
        #expect(expected.count == TypeRole.allCases.count)

        for role in TypeRole.allCases {
            guard let want = expected[role] else {
                Issue.record("\(role) の基準が試験に書かれていない")
                continue
            }
            let got = role.metrics
            #expect(got.size == want.0, "\(role) の大きさ")
            #expect(got.textStyle == want.1, "\(role) の追随先")
            #expect(got.weight == want.2, "\(role) の太さ")
        }
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
