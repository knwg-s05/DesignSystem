import SwiftUI

/// 定義済みのトークンとスタイルを一覧するプレビュー。
///
/// ## これが仕様書の代わり
///
/// 見た目の一覧をスクリーンショットで残すと、実装を変えたときに画像だけ古くなる。
/// プレビューはビルドのたびに実物から描かれるので、ずれようがない。
/// 色を変えたらここを開いて、ライトとダークの両方を確認する。
///
/// `internal` にしてあるのはアプリ側から誤って画面に置かないため。プレビューは
/// 同一モジュール内から解決されるので、これで支障はない。
struct Gallery: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {

                section("色") {
                    swatch("brandAccent(既定の主色)", .brandAccent)
                    swatch("surfaceElevated", .surfaceElevated)
                    swatch("surfaceBackground", .surfaceBackground)
                }

                section("書体") {
                    Text("screenTitle").font(.screenTitle)
                    Text("sectionTitle").font(.sectionTitle)
                    Text("itemTitle").font(.itemTitle)
                    Text("本文 body").font(.body)
                    Text("caption 補足").font(.caption)
                        .foregroundStyle(.contentSecondary)
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

                // アプリ側が .tint を指定した場合の見え方。スタイルは主色を .tint から
                // 引いているので、この 1 行だけで配下すべての配色が変わる。
                section("アプリ側で tint を変えた場合") {
                    VStack(spacing: Spacing.xs) {
                        Button("主要な操作") {}.buttonStyle(.primary)
                        Button("副次的な操作") {}.buttonStyle(.secondary)
                    }
                    .tint(.orange)
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
            }
            .screenPadding()
            .padding(.vertical, Spacing.lg)
        }
        .background(Color.surfaceBackground)
        .tint(.brandAccent)
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
                .fill(.tint)
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
