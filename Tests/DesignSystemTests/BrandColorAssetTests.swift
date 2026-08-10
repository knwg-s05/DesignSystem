import Foundation
import Testing
@testable import DesignSystem

/// `BrandColor` の case と、アセットカタログの colorset が過不足なく対応することを確かめる。
///
/// ## 何が守られていて、何をここで守るか
///
/// アプリ側での綴り間違いは起きない。公開しているのは `Color.brandAccent` のような静的メンバ
/// だけで、`BrandColor` は internal。存在しない色を書けばコンパイルが通らない。
///
/// 残るのはパッケージ内部での食い違い、つまり case 名とフォルダ名がずれる場合。これは
/// コンパイル時には分からず、実行しても落ちない。SwiftUI は解決できない色を例外ではなく
/// 既定色で描画するため、「なんとなく色が違う」という形でしか現れない。ここを検査する。
///
/// ## なぜ実行時の解決ではなく、ソースのフォルダ名を見るか
///
/// 当初は `NSColor(named:bundle:)` で実際に解決できるかを見ようとしたが、成立しなかった。
/// SwiftPM のコマンドラインビルドはアセットカタログを `actool` でコンパイルせず、
/// `.colorset` フォルダのままリソースバンドルへコピーする。`Assets.car` が無いので
/// 名前での解決は常に nil を返す。Xcode 経由のビルドでは逆にコンパイルされ、
/// `.colorset` フォルダはバンドルに残らない。**ビルド経路によって成果物の形が違う。**
///
/// 一方、リポジトリ上の `.colorset` フォルダはどちらの経路でも同じものが入力になる。
/// そこで検査対象を成果物ではなく入力側に置いた。実行時に解決できるかまでは保証しないが、
/// 名前が一致していれば Xcode のビルドで解決されることは `actool` の仕様から従う。
///
/// ## 網羅
///
/// 両方向を見ている。case にフォルダが無ければ描画が既定色に落ち、フォルダに case が無ければ
/// 参照されない資産が残る。照合する一覧は `allCases` とディレクトリの実体から作っており、
/// 手で保守する一覧は無いので、追加時の書き忘れという漏れ方はしない。
///
/// 色の値が意図どおりかは見ていない。それは `Gallery` のプレビューで目視する。
@Suite("ブランド色とアセットカタログの対応")
struct BrandColorAssetTests {

    /// リポジトリ内のアセットカタログ。テストの実行位置ではなくソースの位置から辿るため、
    /// `#filePath` を基点にする。
    private static let catalogURL: URL = {
        URL(fileURLWithPath: #filePath)          // Tests/DesignSystemTests/<this file>
            .deletingLastPathComponent()          // Tests/DesignSystemTests
            .deletingLastPathComponent()          // Tests
            .deletingLastPathComponent()          // パッケージルート
            .appending(path: "Sources/DesignSystem/Resources/Colors.xcassets")
    }()

    /// カタログ直下にある colorset の名前。
    private static func colorSetNames() throws -> Set<String> {
        let entries = try FileManager.default.contentsOfDirectory(
            at: catalogURL,
            includingPropertiesForKeys: nil
        )
        return Set(
            entries
                .filter { $0.pathExtension == "colorset" }
                .map { $0.deletingPathExtension().lastPathComponent }
        )
    }

    @Test("case に対応する colorset がある", arguments: BrandColor.allCases)
    func hasColorSet(_ brandColor: BrandColor) throws {
        let names = try Self.colorSetNames()

        #expect(
            names.contains(brandColor.rawValue),
            """
            colorset '\(brandColor.rawValue).colorset' が見つからない。
            BrandColor に case を足したらアセットカタログにも同名のフォルダを作る。
            現在あるもの: \(names.sorted().joined(separator: ", "))
            """
        )
    }

    @Test("参照されていない colorset が無い")
    func hasNoOrphanColorSet() throws {
        let names = try Self.colorSetNames()
        let declared = Set(BrandColor.allCases.map(\.rawValue))
        let orphans = names.subtracting(declared).sorted()

        #expect(
            orphans.isEmpty,
            """
            BrandColor から参照されていない colorset がある: \(orphans.joined(separator: ", "))
            使うなら case を足し、使わないならフォルダごと消す。
            """
        )
    }
}

extension BrandColor: CustomTestStringConvertible {
    /// 失敗時にどの色かが出るようにする。既定だと引数を並べたときに読みにくい。
    public var testDescription: String { rawValue }
}
