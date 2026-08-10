import SwiftUI

/// 用途で名付けた色。**アプリ側はここに出ている名前だけを使う。**
///
/// 生の値(`Color(red:green:blue:)` や 16 進数)を画面に直接書かないための入口。
/// 名前で参照しておけば、ダークモードの調整や配色の変更をこのファイルの中で完結できる。
///
/// ## 何をアセットカタログに置き、何を置かないか
///
/// SwiftUI と UIKit は既にセマンティックな色を持っている。背景や罫線をアセットカタログで
/// 作り直すと、OS 側の更新(コントラスト設定や新しい外観)に追随できなくなる。
/// そのため **OS が持っている色はそのまま借り、ブランド固有の色だけをアセットカタログに置く**。
///
/// 利用側から見ればどちらも `Color.surfaceBackground` / `Color.brandAccent` という同じ形なので、
/// 後から出自を入れ替えても呼び出し側は変わらない。
public extension Color {

    // MARK: - ブランド固有(アセットカタログ)

    /// このデザインシステムの既定の主色。
    ///
    /// **画面の中で直接使わない。** ボタンなどのスタイルは環境から主色を引いており、
    /// アプリが `.brandTint(...)` を指定すればそちらが優先される。この値は環境の既定であり、
    /// ルートで `.brandTint(.brandAccent)` と明示するためにも公開している。
    ///
    /// 画面の中で `Color.brandAccent` を直に書くと、アプリごとに配色を変えたときに
    /// そこだけ取り残される。主色が欲しい場所では `@Environment(\.brandTint)` を読む。
    static var brandAccent: Color { BrandColor.brandAccent.color }

    // MARK: - OS から借りる色

    /// 画面の一番下の面。
    static var surfaceBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    /// カードやシートなど、背景から一段持ち上がった面。
    static var surfaceElevated: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    /// 面と面の境界に引く線。
    static var separator: Color {
        #if canImport(UIKit)
        Color(uiColor: .separator)
        #else
        Color(nsColor: .separatorColor)
        #endif
    }

    /// 本文。`Color.primary` と同じだが、名前を揃えるために置いている。
    static var contentPrimary: Color { .primary }

    /// 補足、キャプション。
    static var contentSecondary: Color { .secondary }

    /// 3 段目の文字。日付、単位、無効時のラベルなど、補足よりさらに弱めたいもの。
    ///
    /// iOS の文字色は `label` → `secondaryLabel` → `tertiaryLabel` → `quaternaryLabel` の
    /// 4 段になっている。Web でよくある数値の段(`gray-400` など)を自作すると、ダークモードや
    /// コントラストを上げる設定へ追随しなくなるので、OS の段をそのまま借りる。
    static var contentTertiary: Color {
        #if canImport(UIKit)
        Color(uiColor: .tertiaryLabel)
        #else
        Color(nsColor: .tertiaryLabelColor)
        #endif
    }

    /// 要素そのものを塗る色。タグ、進捗の溝、区切りのブロックなど。
    ///
    /// `surfaceElevated` は「背景から持ち上がった面」で、こちらは「背景の上に置く要素の塗り」。
    /// 役割が違うので分けている。iOS の `systemFill` 系は、背景色ではなく要素の塗りとして
    /// 調整された値になっている。
    static var fill: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemFill)
        #else
        Color(nsColor: .controlColor)
        #endif
    }

    /// `fill` より薄い塗り。押されていない状態の背景など、存在を主張させたくないもの。
    static var fillSubtle: Color {
        #if canImport(UIKit)
        Color(uiColor: .quaternarySystemFill)
        #else
        Color(nsColor: .quaternaryLabelColor)
        #endif
    }
}

/// `.foregroundStyle(.brandAccent)` のように前置きのドットで書けるようにする。
///
/// `Color` の静的メンバだけでは `ShapeStyle` を要求する引数で型が推論されず、
/// 呼び出し側が毎回 `Color.` を書くことになる。
public extension ShapeStyle where Self == Color {
    static var brandAccent: Color { .brandAccent }
    static var surfaceBackground: Color { .surfaceBackground }
    static var surfaceElevated: Color { .surfaceElevated }
    static var contentPrimary: Color { .contentPrimary }
    static var contentSecondary: Color { .contentSecondary }
    static var contentTertiary: Color { .contentTertiary }
    static var fill: Color { .fill }
    static var fillSubtle: Color { .fillSubtle }
}
