/// WCAG の相対輝度とコントラスト比を扱う小さな計算。
///
/// SwiftUI の `Color` は環境を通して実色へ解決されるため、ここでは解決後の線形RGBだけを受け取る。
/// View の描画と切り離すことで、コントラストの判断をUnit testで固定できる。
struct RelativeLuminance {
    let value: Double

    init(linearRed: Double, linearGreen: Double, linearBlue: Double) {
        value = 0.2126 * linearRed
            + 0.7152 * linearGreen
            + 0.0722 * linearBlue
    }

    static let white = RelativeLuminance(value: 1.0)
    static let black = RelativeLuminance(value: 0.0)

    private init(value: Double) {
        self.value = value
    }

    func contrastRatio(against other: RelativeLuminance) -> Double {
        let lighter = max(value, other.value)
        let darker = min(value, other.value)

        return (lighter + 0.05) / (darker + 0.05)
    }
}
