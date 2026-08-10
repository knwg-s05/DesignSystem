import Foundation
import SwiftUI
import Testing
@testable import DesignSystem

/// `GalleryContent` を PNG として書き出す。
///
/// ## テストの体裁を借りている理由
///
/// 画像を描くには SwiftUI を実際に動かす必要があり、そのためには iOS を動かす場所が要る。
/// パッケージ単体で iOS のコードを実行できるのはテストの実行環境だけなので、判定ではなく
/// 書き出しの入れ物としてテストを使っている。
///
/// ## 既定では動かない
///
/// 環境変数 `GALLERY_EXPORT_PATH` が設定されているときだけ実行する。`swift test` は macOS 上で
/// 走るため、そのまま描くと iOS ではなく macOS の見た目になる。意図しない画像を作らないよう、
/// 明示的に出力先を渡されたときに限って動かす。
///
/// 実行は `Scripts/gallery.sh` から。iOS シミュレータを指定し、`TEST_RUNNER_` 接頭辞で
/// 環境変数をテストプロセスへ渡している。
@Suite("一覧の画像を書き出す")
struct GalleryExportTests {

    private static let outputPath = ProcessInfo.processInfo.environment["GALLERY_EXPORT_PATH"]

    /// 書き出す幅。iPhone の一般的な論理幅に合わせる。
    private static let width: CGFloat = 393

    @Test(
        "ライトとダークを PNG にする",
        .enabled(if: outputPath != nil),
        arguments: [ColorScheme.light, ColorScheme.dark]
    )
    @MainActor
    func export(_ scheme: ColorScheme) throws {
        let directory = URL(fileURLWithPath: try #require(Self.outputPath))
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let renderer = ImageRenderer(
            content: GalleryContent()
                .frame(width: Self.width)
                .environment(\.colorScheme, scheme)
        )
        // 実機と同じ密度で描く。1 倍だと文字の輪郭が潰れて配色の確認に使えない。
        renderer.scale = 3

        let name = scheme == .light ? "gallery-light" : "gallery-dark"
        let destination = directory.appending(path: "\(name).png")

        #if canImport(UIKit)
        let image = try #require(renderer.uiImage, "ImageRenderer が画像を返さなかった")
        let data = try #require(image.pngData(), "PNG へ変換できなかった")
        #else
        let image = try #require(renderer.nsImage, "ImageRenderer が画像を返さなかった")
        let tiff = try #require(image.tiffRepresentation)
        let data = try #require(NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]))
        #endif

        try data.write(to: destination)

        // 書き出し先はテストプロセスの外(ホスト側)なので、実際に残ったことまで確かめる。
        #expect(FileManager.default.fileExists(atPath: destination.path))
        print("書き出した: \(destination.path)")
    }
}
