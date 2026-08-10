import SwiftUI

/// 背景から一段持ち上がった面。
///
/// 影ではなく面の色で段差を出している。影は暗い背景では見えず、ダークモードで段差が
/// 消える。色で分けておけばどちらの外観でも成立する。
public struct CardModifier: ViewModifier {

    private let padding: CGFloat

    public init(padding: CGFloat = Spacing.md) {
        self.padding = padding
    }

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.surfaceElevated, in: .rect(cornerRadius: Radius.lg))
    }
}

public extension View {
    /// カードとして表示する。
    ///
    /// 内側にさらに角丸を置くときは、`Radius.lg` から余白を引いた値を使うと同心円になる。
    func card(padding: CGFloat = Spacing.md) -> some View {
        modifier(CardModifier(padding: padding))
    }

    /// 画面の標準的な左右余白を付ける。
    ///
    /// 画面ごとに `.padding(.horizontal, 16)` と書くと、後で余白を変えるときに
    /// 全画面を触ることになる。名前で参照しておけばここだけで変えられる。
    func screenPadding() -> some View {
        padding(.horizontal, Spacing.md)
    }
}
