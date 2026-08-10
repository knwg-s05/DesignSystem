import CoreGraphics

/// 余白の刻み。4pt を単位とする。
///
/// 刻みを決めておく目的は見た目の統一そのものより、**毎回どの数字にするか考えないため**。
/// 選択肢が 6 つに閉じていれば、余白は迷う対象でなくなる。
///
/// 段階は上へ行くほど倍率を上げてある(4, 8, 12, 16, 24, 32)。等差にすると、大きい側で
/// 隣の段との差が相対的に小さくなり、区別が付かない段が増える。
public enum Spacing {
    /// 4pt。アイコンと文字の間など、くっついて見えてよい距離。
    public static let xxs: CGFloat = 4
    /// 8pt。関連する要素どうし。
    public static let xs: CGFloat = 8
    /// 12pt。行と行の間。
    public static let sm: CGFloat = 12
    /// 16pt。画面の左右の余白、カードの内側。既定値として最初に試す値。
    public static let md: CGFloat = 16
    /// 24pt。まとまりとまとまりの間。
    public static let lg: CGFloat = 24
    /// 32pt。節の区切り。
    public static let xl: CGFloat = 32
}

/// 角丸の半径。
///
/// 入れ子にする場合、外側の半径から内側の余白を引いた値を内側に使うと同心円になる。
/// 例: 外 `Radius.lg`(16) のカードの中に `Spacing.xs`(8) の余白で置く要素は `Radius.xs`(8)。
public enum Radius {
    /// 4pt。バッジ、小さなタグ。
    public static let xs: CGFloat = 4
    /// 8pt。ボタン、入力欄。
    public static let sm: CGFloat = 8
    /// 12pt。リストの行。
    public static let md: CGFloat = 12
    /// 16pt。カード、シート。
    public static let lg: CGFloat = 16
}
