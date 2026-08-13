import SwiftUI

/// 画面内容の上へ一時的に重ねる面。
///
/// 会話、設定、確認など、背後の画面を残したまま前面で読ませる用途に使う。
/// 通常のカードより境界を強め、ゲーム画面や画像の上でも面として分かるようにする。
public struct OverlayPanelModifier: ViewModifier {

    private let padding: CGFloat

    public init(padding: CGFloat = Spacing.md) {
        self.padding = padding
    }

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.surfaceElevated, in: .rect(cornerRadius: Radius.lg))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(Color.separator, lineWidth: 1)
            }
    }
}

/// ゲーム画面や画像の上へ置く、軽い情報表示の面。
///
/// 目的表示、短い状態、デバッグ情報など、主内容を遮らず確認したいものに使う。
/// 内側の余白は通常カードより小さくし、面の主張を抑える。
public struct HUDPanelModifier: ViewModifier {

    private let padding: CGFloat

    public init(padding: CGFloat = Spacing.xs) {
        self.padding = padding
    }

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.surfaceElevated.opacity(0.92), in: .rect(cornerRadius: Radius.md))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(Color.contentPrimary.opacity(0.2), lineWidth: 1)
            }
    }
}

/// 短い状態を示すラベル。
///
/// 保存済み、警戒、ヒントありなど、1語から数語で済む状態へ使う。
/// 詳細説明やアプリ固有の意味は持たせず、表示の密度だけを揃える。
public struct StatusBadgeModifier: ViewModifier {

    @Environment(\.brandTint) private var brandTint

    private let tint: Color?

    public init(tint: Color? = nil) {
        self.tint = tint
    }

    public func body(content: Content) -> some View {
        let resolvedTint = tint ?? brandTint

        content
            .font(.caption)
            .foregroundStyle(.contentPrimary)
            .padding(.vertical, Spacing.xxs)
            .padding(.horizontal, Spacing.xs)
            .background(resolvedTint.opacity(0.16), in: .rect(cornerRadius: Radius.xs))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.xs)
                    .stroke(resolvedTint.opacity(0.32), lineWidth: 1)
            }
    }
}

public extension View {
    /// 背後を残したまま前面で読ませる面として表示する。
    func overlayPanel(padding: CGFloat = Spacing.md) -> some View {
        modifier(OverlayPanelModifier(padding: padding))
    }

    /// ゲーム画面や画像の上へ置く軽い情報面として表示する。
    func hudPanel(padding: CGFloat = Spacing.xs) -> some View {
        modifier(HUDPanelModifier(padding: padding))
    }

    /// 短い状態ラベルとして表示する。
    func statusBadge(tint: Color? = nil) -> some View {
        modifier(StatusBadgeModifier(tint: tint))
    }
}
