import SwiftUI

/// 主要な操作に使うボタン。画面に 1 つまで。
///
/// ## なぜ View ではなく ButtonStyle か
///
/// `struct PrimaryButton: View { ... }` のように包む作り方もあるが、その場合
/// `Button` が持っている挙動を自分で作り直すことになる。押下中の判定、長押しでの取り消し
/// (指を離す前に外へずらすと発火しない)、`.disabled` の伝播、VoiceOver がボタンとして
/// 読み上げること、キーボード操作でのフォーカス。これらは無償ではない。
///
/// `ButtonStyle` は見た目だけを差し替える口として用意されているので、挙動は `Button` の
/// ものがそのまま残る。利用側も `Button("保存") { ... }.buttonStyle(.primary)` と書けて、
/// 標準の書き方から外れない。
public struct PrimaryButtonStyle: ButtonStyle {

    /// 押されているかどうかは `configuration` から来るが、無効かどうかは環境から取る。
    /// `ButtonStyle` の `configuration` には有効・無効が含まれていないため。
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.actionLabel)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .background(Color.brandAccent, in: .rect(cornerRadius: Radius.sm))
            .opacity(isEnabled ? 1 : 0.4)
            // 押下の表現は縮小と減光の両方を弱くかける。片方だけだと、色の薄い端末設定や
            // 動きを減らす設定のもとで反応が伝わらないことがある。
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// 副次的な操作に使うボタン。並記される選択肢や、取り消し寄りの操作。
public struct SecondaryButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.actionLabel)
            .foregroundStyle(.brandAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .background(Color.brandAccentSubtle, in: .rect(cornerRadius: Radius.sm))
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// `.buttonStyle(.primary)` と書けるようにする。
///
/// `.buttonStyle(PrimaryButtonStyle())` でも動くが、標準スタイル(`.bordered` など)と
/// 書き方が揃わないと、利用側で書式が混ざる。
public extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

public extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}
