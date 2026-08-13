import SwiftUI

/// 定義済みのトークンとスタイルを一覧するプレビュー。
///
/// ## これが仕様書の代わり
///
/// 見た目の一覧をスクリーンショットで残すと、実装を変えたときに画像だけ古くなる。
/// プレビューはビルドのたびに実物から描かれるので、ずれようがない。
/// 色を変えたらここを開いて、ライトとダークの両方を確認する。
///
/// PNG として書き出したいときは `Scripts/gallery.sh` を使う。こちらも同じ
/// `GalleryContent` を実行時に描画するので、画像と実装がずれることはない。
///
/// `internal` にしてあるのはアプリ側から誤って画面に置かないため。プレビューは
/// 同一モジュール内から解決されるので、これで支障はない。
struct Gallery: View {
    var body: some View {
        ScrollView {
            GalleryContent()
        }
        .background(Color.surfaceBackground)
    }
}

/// 一覧の中身。スクロールを含まない。
///
/// `Gallery` から分けてあるのは画像として書き出すため。`ImageRenderer` は与えられた
/// 内容の必要な大きさを測って描くが、`ScrollView` は「与えられた高さいっぱい」を主張する
/// ので、そのまま渡すと中身が切れる。スクロールを外側に置けば、書き出しでは全体が、
/// プレビューでは通常どおりスクロールする形になる。
struct GalleryContent: View {

    @Environment(\.brandTint) private var brandTint

    /// 主色を差し替えたときの見え方を確かめるための一覧。
    /// 明るい色を含めているのは、文字色が自動で黒へ切り替わることを確認するため。
    private let tintVariations: [(String, Color)] = [
        ("brandAccent(既定)", .brandAccent),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("pink", .pink),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {

            section("色") {
                swatch("brandAccent(既定の主色)", .brandAccent)
                swatch("surfaceBackground", .surfaceBackground)
                swatch("surfaceElevated", .surfaceElevated)
                swatch("fill", .fill)
                swatch("fillSubtle", .fillSubtle)
                swatch("separator", .separator)
            }

            section("書体") {
                Text("screenTitle").font(.screenTitle)
                Text("sectionTitle").font(.sectionTitle)
                Text("itemTitle").font(.itemTitle)
                Text("本文 body").font(.body)
                Text("caption 補足").font(.caption)
                    .foregroundStyle(.contentSecondary)
                Text("caption 3 段目").font(.caption)
                    .foregroundStyle(.contentTertiary)
            }

            section("余白") {
                bar("xxs", Spacing.xxs)
                bar("xs", Spacing.xs)
                bar("sm", Spacing.sm)
                bar("md", Spacing.md)
                bar("lg", Spacing.lg)
                bar("xl", Spacing.xl)
            }

            section("ボタン") {
                Button("主要な操作") {}.buttonStyle(.primary)
                Button("副次的な操作") {}.buttonStyle(.secondary)
                Button("無効") {}.buttonStyle(.primary).disabled(true)
            }

            // アプリ側が主色を変えた場合の見え方。スタイルは主色を環境から引いているので、
            // .brandTint(_:) を 1 行書くだけで配下すべての配色が変わる。
            //
            // 明るい色(yellow、green)で文字が黒へ切り替わることがここで確認できる。
            // 白のまま固定していると、この 2 行が読めなくなる。
            section("主色を変えた場合") {
                ForEach(tintVariations, id: \.0) { name, color in
                    HStack(spacing: Spacing.xs) {
                        Text(name)
                            .font(.caption)
                            .frame(width: 120, alignment: .leading)
                        Button("主要な操作") {}.buttonStyle(.primary)
                    }
                    .brandTint(color)
                }
            }

            section("カード") {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("カードの見出し").font(.itemTitle)
                    Text("面の色で背景から持ち上げる。影は使わない。")
                        .font(.caption)
                        .foregroundStyle(.contentSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .card()
            }

            section("パネルとバッジ") {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("前面に重ねる読み物").font(.itemTitle)
                    Text("背後の画面を残したまま、会話や設定を読ませる。")
                        .font(.body)
                    HStack(spacing: Spacing.xs) {
                        Text("保存済み").statusBadge()
                        Text("注意").statusBadge(tint: .orange)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlayPanel()

                HStack(spacing: Spacing.xs) {
                    Text("目的: 手掛かりを探す").font(.caption)
                    Text("ヒントあり").statusBadge()
                }
                .hudPanel()
            }

            section("体験別の密度") {
                readingScenario
                hudScenario
                smallLandscapeScenario
            }
        }
        .screenPadding()
        .padding(.vertical, Spacing.lg)
        .background(Color.surfaceBackground)
        .brandTint(.brandAccent)
    }

    private var readingScenario: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("読み物オーバーレイ").font(.itemTitle)
            Text("短い履歴を残しながら、現在の本文を読む。")
                .font(.caption)
                .foregroundStyle(.contentSecondary)
            Text("前の行は弱く、現在の行は本文として出す。")
                .font(.body)
            HStack {
                Button("全文表示") {}.buttonStyle(.secondary)
                Button("次へ") {}.buttonStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlayPanel()
    }

    private var hudScenario: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [.green.opacity(0.35), .blue.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 132)
            .clipShape(.rect(cornerRadius: Radius.lg))

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("MVP-00").font(.caption)
                Text("Core save format v1")
                    .font(.caption)
                    .foregroundStyle(.contentSecondary)
            }
            .hudPanel()
            .padding(Spacing.xs)
        }
    }

    private var smallLandscapeScenario: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [.black.opacity(0.82), .blue.opacity(0.28)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 172)
            .clipShape(.rect(cornerRadius: Radius.lg))

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text("小画面横向き").font(.itemTitle)
                    Spacer()
                    Text("Auto").statusBadge()
                }
                Text("横向きの狭い高さでも、本文と主要操作が押せる密度に収まるかを見る。")
                    .font(.caption)
            }
            .overlayPanel(padding: Spacing.sm)
            .padding(Spacing.xs)
        }
    }

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.sectionTitle)
            content()
        }
    }

    private func swatch(_ name: String, _ color: Color) -> some View {
        HStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: Radius.xs)
                .fill(color)
                .frame(width: 44, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xs)
                        .stroke(Color.separator)
                )
            Text(name).font(.caption)
        }
    }

    private func bar(_ name: String, _ value: CGFloat) -> some View {
        HStack(spacing: Spacing.xs) {
            Rectangle()
                .fill(brandTint)
                .frame(width: value, height: 12)
            Text("\(name) — \(Int(value))pt").font(.caption)
        }
    }
}

#Preview("ライト") {
    Gallery()
        .preferredColorScheme(.light)
}

#Preview("ダーク") {
    Gallery()
        .preferredColorScheme(.dark)
}
