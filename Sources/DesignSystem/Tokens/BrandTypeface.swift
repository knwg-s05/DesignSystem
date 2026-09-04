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

    /// 書体を渡されなかったときの font。**`Typography.swift` の定義と同じものを返す。**
    /// ここがずれると、書体を渡さないアプリの見た目が変わる。
    public var systemFont: Font {
        switch self {
        case .screenTitle: return .screenTitle
        case .sectionTitle: return .sectionTitle
        case .itemTitle: return .itemTitle
        case .body: return .body
        case .caption: return .caption
        case .actionLabel: return .actionLabel
        }
    }

    /// 独自の書体を使うときの基準。`size` は各テキストスタイルの既定の大きさ、
    /// `textStyle` は Dynamic Type の追随先。
    ///
    /// ⚠️ **`Typography.swift` の定義と対になっている。片方だけを変えない。**
    /// 大きさも weight も `Font` の値からは読み出せないため、ここが二重に持つ唯一の場所になる。
    /// `Typography.swift` の役割を変えたら、ここも同じ意味へ直すこと。直さないと、
    /// **書体を渡したアプリだけが古い大きさのまま**になる (渡さないアプリでは気付けない)。
    var metrics: (size: CGFloat, textStyle: Font.TextStyle, weight: Font.Weight) {
        switch self {
        case .screenTitle: return (34, .largeTitle, .bold)
        case .sectionTitle: return (20, .title3, .semibold)
        case .itemTitle: return (17, .headline, .semibold)
        case .body: return (17, .body, .regular)
        case .caption: return (13, .footnote, .regular)
        case .actionLabel: return (17, .body, .semibold)
        }
    }

    /// この役割の font。`typeface` が `nil` なら OS のテキストスタイルをそのまま使う。
    ///
    /// ⚠️ **`relativeTo:` を必ず渡す。**`Font.custom(_:size:)` だけだと、利用者が設定アプリで
    /// 文字を大きくしても追随しない。
    public func font(typeface: String?) -> Font {
        guard let typeface, !typeface.isEmpty else { return systemFont }
        let m = metrics
        return .custom(typeface, size: m.size, relativeTo: m.textStyle).weight(m.weight)
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
