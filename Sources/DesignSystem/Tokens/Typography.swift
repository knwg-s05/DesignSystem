import SwiftUI

/// 書体の役割。
///
/// ## なぜ固定のポイント数を持たないか
///
/// `Font.system(size: 17)` と書くと、利用者が設定アプリで文字サイズを変えても追随しない。
/// iOS のテキストスタイル(`.body`、`.headline` など)を土台にすれば、Dynamic Type が
/// そのまま効き、太字設定やアクセシビリティ用の特大サイズにも自動で対応する。
///
/// つまりここでやっているのは大きさの定義ではなく、**役割と OS のテキストスタイルの対応付け**。
///
/// ## カスタムフォントを入れるとき
///
/// `Font.custom("YourFont", size: 17)` は Dynamic Type を殺す。必ず
/// `Font.custom("YourFont", size: 17, relativeTo: .body)` の形で基準スタイルを指定する。
/// 加えて、パッケージに同梱したフォントはアプリの Info.plist では登録されないため、
/// `CTFontManagerRegisterFontsForURL` による明示的な登録処理が別途要る。
public extension Font {
    /// 画面の題。1 画面に 1 つ。
    static var screenTitle: Font { .largeTitle.weight(.bold) }
    /// 節の題。
    static var sectionTitle: Font { .title3.weight(.semibold) }
    /// カードやリスト行の見出し。
    static var itemTitle: Font { .headline }
    /// 本文。
    static var body: Font { .system(.body) }
    /// 補足。日付、単位、状態の説明。
    static var caption: Font { .footnote }
    /// ボタンの文字。
    static var actionLabel: Font { .body.weight(.semibold) }
}
