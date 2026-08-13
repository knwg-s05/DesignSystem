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
///
/// ## 色を固定しない
///
/// 主色は `Color.brandAccent` を直接使わず、環境から引いている。アプリ側が
/// `.brandTint(Color.parkGreen)` と書けばその配下すべてへ伝わる。
///
/// ## 文字色を白で固定しない
///
/// 塗りが主色で、その上に文字を置く。主色は明るい色にもなりうるので、白固定では
/// 読めなくなる場合がある(黄や薄い緑を渡されたときが該当する)。塗りの明るさから
/// 白か黒かを決める。判定は `Color.contrastingLabel(in:)` にある。
///
/// アプリがどの色を選んでも文字が読めることは、配色をアプリに委ねている以上、
/// こちらの責任として扱う。規約で「明るい色を渡さない」と書く形にはしない。
public struct PrimaryButtonStyle: ButtonStyle {

    /// 押されているかどうかは `configuration` から来るが、無効かどうかは環境から取る。
    /// `ButtonStyle` の `configuration` には有効・無効が含まれていないため。
    @Environment(\.isEnabled) private var isEnabled

    @Environment(\.brandTint) private var brandTint

    /// 色の解決には環境一式が要る(ダークモードやコントラスト設定で値が変わるため)。
    @Environment(\.self) private var environment

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.actionLabel)
            .foregroundStyle(brandTint.contrastingLabel(in: environment))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .background(brandTint, in: .rect(cornerRadius: Radius.sm))
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

    @Environment(\.brandTint) private var brandTint

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.actionLabel)
            .foregroundStyle(.contentPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            // 主色は面へだけ使う。文字まで主色にすると、明るい主色で薄い面との
            // コントラストが足りなくなる。
            .background(brandTint.opacity(0.15), in: .rect(cornerRadius: Radius.sm))
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
