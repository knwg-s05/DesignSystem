import SwiftUI

public extension View {

    /// このデザインシステムの主色を指定する。配下すべてに伝わる。
    ///
    /// ```swift
    /// ContentView()
    ///     .brandTint(.brandAccent)
    /// ```
    ///
    /// ## `.tint(_:)` ではなくこちらを使う理由
    ///
    /// 主要ボタンは主色で塗り、その上に文字を置く。文字の色は塗りの明るさによって
    /// 白か黒かが変わる。明るい主色(黄や薄い緑)に白文字を置くと読めなくなるため、
    /// **塗りの色の値を知る必要がある**。
    ///
    /// ところが SwiftUI は `.tint(_:)` で設定された色を読み出す口を用意していない
    /// (`EnvironmentValues` に該当するプロパティが無い)。そのため主色は自前の環境値として
    /// 持ち、この修飾子が同時に `.tint(_:)` も適用する形にしている。標準コントロール
    /// (`Toggle`、`Picker` など)は従来どおり `.tint` に追随する。
    ///
    /// アプリが `.tint(_:)` を直接使った場合、標準コントロールはその色になるが、
    /// このデザインシステムのスタイルは主色を変えない。読めない文字が出るより、
    /// 色が揃わないほうが害が小さいという判断で、この向きに倒している。
    func brandTint(_ color: Color) -> some View {
        environment(\.brandTint, color)
            .tint(color)
    }
}

extension EnvironmentValues {
    /// デザインシステムの主色。既定はアセットカタログの `brandAccent`。
    @Entry var brandTint: Color = .brandAccent
}

extension Color {

    /// この色を背景に置いたとき、文字として読める側(白か黒)を返す。
    ///
    /// WCAG の相対輝度とコントラスト比の定義に従い、白と黒それぞれとの比を求めて
    /// 大きいほうを選ぶ。閾値を決め打ちにしていないのは、境界付近での挙動を
    /// 定義どおりにするため。
    ///
    /// `Color.Resolved` の `linearRed` などはガンマ補正を戻した線形の値で、相対輝度の
    /// 定義がそのまま使える。`red` などの sRGB の値を使うと暗い色を過大に評価する。
    func contrastingLabel(in environment: EnvironmentValues) -> Color {
        let resolved = resolve(in: environment)

        let luminance = RelativeLuminance(
            linearRed: Double(resolved.linearRed),
            linearGreen: Double(resolved.linearGreen),
            linearBlue: Double(resolved.linearBlue)
        )

        let againstWhite = luminance.contrastRatio(against: .white)
        let againstBlack = luminance.contrastRatio(against: .black)

        return againstWhite >= againstBlack ? .white : .black
    }
}
