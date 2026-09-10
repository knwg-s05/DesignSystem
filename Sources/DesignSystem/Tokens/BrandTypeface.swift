import SwiftUI

/// 書体の役割。`Font` の静的メンバ (`Typography.swift`) と 1 対 1 で対応する。
///
/// ## なぜ役割を型にするか
///
/// アプリが独自の書体を渡せるようにするには、**役割ごとに「基準となるテキストスタイル」と
/// 「大きさ」を知っている必要がある。**`Font.custom(_:size:)` は Dynamic Type を殺すため、
/// `relativeTo:` に基準スタイルを渡さなければならないが、`Font` の値からは基準スタイルを
/// 読み出せない。そこで役割を型にし、両方をここに持たせる。
public enum TypeRole: CaseIterable, Sendable {
    /// 画面の題。1 画面に 1 つ。
    case screenTitle
    /// 節の題。
    case sectionTitle
    /// カードやリスト行の見出し。
    case itemTitle
    /// 本文。
    case body
    /// 補足。日付、単位、状態の説明。
    case caption
    /// ボタンの文字。
    case actionLabel

    /// 書体を渡されなかったときの font。**`metrics` から組み立てる。**
    ///
    /// ⚠️ **ここと `metrics` を別々に持たない。**別々に持つと、片方だけ変えたときに
    /// 「書体を渡したアプリだけが古い大きさ」という、**渡さないアプリでは気付けない**
    /// ずれ方をする。出どころを 1 つにすれば、そのずれ方自体が起きない。
    public var systemFont: Font {
        let m = metrics
        let base = Font.system(m.textStyle)
        return m.systemWeight.map { base.weight($0) } ?? base
    }

    /// 役割の見え方。**`Typography.swift` の静的メンバも、名前付き書体の組み立ても、
    /// 両方ここから導く。**役割の見え方を変えるときは、ここだけを変える。
    ///
    /// - `size`: そのテキストスタイルの既定の大きさ。名前付き書体を組むときの基準
    /// - `textStyle`: Dynamic Type の追随先
    /// - `systemWeight`: OS のテキストスタイルへ重ねる太さ。**`nil` は「重ねない」。**
    /// - `customWeight`: 名前付き書体へ与える太さ。**`nil` はその書体の既定のまま。**
    ///
    /// ⚠️ **2 つの太さが違う役割がある。**`headline` は**テキストスタイル自体が太い**ので、
    /// OS 側へ `.semibold` を重ねると別の値になってしまう (`systemWeight` は `nil`)。
    /// 一方 `relativeTo:` は Dynamic Type の追随先を指すだけで**太さを継がない**ため、
    /// 名前付き書体には明示しないと見出しが細くなる (`customWeight` は `.semibold`)。
    /// `body` と `caption` の `nil` は理由が別で、**既定の値をそのまま保つため**
    /// (`.weight(.regular)` を重ねると `Font` の値としては別物になる)。
    var metrics: (size: CGFloat, textStyle: Font.TextStyle,
                  systemWeight: Font.Weight?, customWeight: Font.Weight?) {
        switch self {
        case .screenTitle: return (34, .largeTitle, .bold, .bold)
        case .sectionTitle: return (20, .title3, .semibold, .semibold)
        case .itemTitle: return (17, .headline, nil, .semibold)
        case .body: return (17, .body, nil, nil)
        case .caption: return (13, .footnote, nil, nil)
        case .actionLabel: return (17, .body, .semibold, .semibold)
        }
    }

    /// この役割の font。`typeface` が `nil` なら OS のテキストスタイルをそのまま使う。
    ///
    /// ⚠️ **`relativeTo:` を必ず渡す。**`Font.custom(_:size:)` だけだと、利用者が設定アプリで
    /// 文字を大きくしても追随しない。
    public func font(typeface: String?) -> Font {
        guard let typeface, !typeface.isEmpty else { return systemFont }
        let m = metrics
        let font = Font.custom(typeface, size: m.size, relativeTo: m.textStyle)
        return m.customWeight.map { font.weight($0) } ?? font
    }
}

public extension View {

    /// このデザインシステムが使う書体を指定する。配下すべてに伝わる。
    ///
    /// ```swift
    /// ContentView()
    ///     .brandTypeface("HiraMaruProN-W4")
    /// ```
    ///
    /// ## 主色と同じ形にしている理由
    ///
    /// 書体の選び方はアプリの性格そのもの (丸い書体を選ぶのは、その画面が誰に向くかの判断) で、
    /// **どのアプリでも意味が変わらないもの**ではない。主色を `.brandTint(_:)` でアプリから
    /// 渡しているのと同じ理由で、実体はアプリ側に置き、ここは受け取る口だけを持つ。
    ///
    /// ## 渡さないアプリは変わらない
    ///
    /// 既定は `nil` で、そのときは OS のテキストスタイルをそのまま使う (`TypeRole.systemFont`)。
    ///
    /// ## 同梱フォントを使う場合
    ///
    /// パッケージやアプリに同梱したフォントファイルは、Info.plist に登録しない限り名前で
    /// 解決できない。OS 同梱の書体 (ヒラギノなど) は登録が要らない。
    func brandTypeface(_ name: String?) -> some View {
        environment(\.brandTypeface, name)
    }

    /// 役割に応じた font を当てる。アプリが渡した書体があればそれを使う。
    ///
    /// `.font(.actionLabel)` と違い、**環境から書体を読む。**この語彙を使うスタイルは
    /// すべてこちらを通すこと。
    func brandFont(_ role: TypeRole) -> some View {
        modifier(BrandFontModifier(role: role))
    }
}

extension EnvironmentValues {
    /// アプリが指定した書体の名前。`nil` なら OS のテキストスタイルを使う。
    @Entry var brandTypeface: String? = nil
}

struct BrandFontModifier: ViewModifier {
    let role: TypeRole
    @Environment(\.brandTypeface) private var typeface

    func body(content: Content) -> some View {
        content.font(role.font(typeface: typeface))
    }
}
