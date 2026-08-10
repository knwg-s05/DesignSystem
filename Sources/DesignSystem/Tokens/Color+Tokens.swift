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
    /// **画面の中で直接使わない。** ボタンなどのスタイルは `.tint` を通して主色を引いており、
    /// アプリが `.tint(...)` を指定すればそちらが優先される。この値は、アプリ側で
    /// 何も指定しないときの既定として、ルートで `.tint(.brandAccent)` と書くために公開している。
    ///
    /// 画面の中で `Color.brandAccent` を直に書くと、アプリごとに配色を変えたときに
    /// そこだけ取り残される。主色が欲しい場所では `.tint` を使う。
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

    /// 補足、キャプション、無効時の文字。
    static var contentSecondary: Color { .secondary }
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
}
