// swift-tools-version: 6.0
import PackageDescription

// DesignSystem は表示の語彙(余白・角丸・書体・色・スタイル)だけを持つ層。
// ParkApp / BalloonPop / AnimalGarden から参照する。
//
// ここにアプリ固有の概念を入れない。判断基準は「型名にドメインの語が入るかどうか」で、
// PrimaryButtonStyle は入れてよく、BalloonCard や AnimalCard は入れない。
// 入れると 2 本目のアプリが 1 本目の語彙を引きずり、共有する利点が消える。
let package = Package(
    name: "DesignSystem",
    platforms: [
        // アプリ側の製品要件に合わせる(AnimalGarden は iOS 18 以上)。
        .iOS(.v18),
        // macOS は CI で swift test を動かすためだけに指定する。配布対象ではない。
        .macOS(.v14),
    ],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    targets: [
        .target(
            name: "DesignSystem",
            // アセットカタログはバンドル別になるため、参照側で bundle: .module が要る。
            // その面倒を利用側へ出さないよう、Color.swift で包んでから公開する。
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"]
        ),
    ]
)
