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
/// ⚠️ **値の出どころは `TypeRole.metrics` の 1 か所。**ここは呼びやすい名前を与えるだけ。
/// 役割の見え方を変えるときは `BrandTypeface.swift` の `metrics` を直す。
/// ここで別の値を書くと、名前付き書体を渡したアプリだけが古い見え方のまま残る。
public extension Font {
    /// 画面の題。1 画面に 1 つ。
    static var screenTitle: Font { TypeRole.screenTitle.systemFont }
    /// 節の題。
    static var sectionTitle: Font { TypeRole.sectionTitle.systemFont }
    /// カードやリスト行の見出し。
    static var itemTitle: Font { TypeRole.itemTitle.systemFont }
    /// 本文。
    static var body: Font { TypeRole.body.systemFont }
    /// 補足。日付、単位、状態の説明。
    static var caption: Font { TypeRole.caption.systemFont }
    /// ボタンの文字。
    static var actionLabel: Font { TypeRole.actionLabel.systemFont }
}
