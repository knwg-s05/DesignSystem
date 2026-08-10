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
        // 参照するアプリのうち最も低い下限に合わせる。対応 OS はアプリ側の要件であり、
        // 共有パッケージの都合で動かさない。現在の下限は AnimalGarden の iOS 18。
        //
        // このパッケージのコードは iOS 26 を必要としない。ボタンとカードは ButtonStyle と
        // ViewModifier で見た目を自前で描いており、iOS 26 で刷新された標準コントロールの
        // 描画には乗っていない。色はセマンティック色を借りているので OS 側の外観更新へ
        // 自動で追随し、書体はテキストスタイルへの対応付けなので OS 版に依存しない。
        //
        // 以前ここを 26 にしていたのは「2 つの視覚言語を抱えたくない」という方針判断で、
        // 技術的な制約ではなかった。その懸念が効くのは標準コントロールを多用する
        // アプリ側であって、自前描画しかしていないこの層には当てはまらない。
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
