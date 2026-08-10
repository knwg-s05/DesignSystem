import SwiftUI

/// アセットカタログの colorset を指す名前。**パッケージ内で文字列を書いてよい唯一の場所。**
///
/// ## なぜ enum に集約するか
///
/// `Color("brandAccent", bundle: .module)` は名前を間違えても実行時に落ちない。
/// SwiftUI は解決できない色を既定色で描画するため、間違いが「なんとなく色が違う」という
/// 形でしか現れず、気づくのが遅れる。
///
/// そこで守り方を二段に分ける。
///
/// 1. **利用側からは文字列を書けなくする。** この型は internal で、アプリへ公開するのは
///    `Color.brandAccent` のような静的メンバだけ(`Color+Tokens.swift`)。存在しない色を
///    書けばコンパイルエラーになり、綴り間違いという事象自体が起きない。
/// 2. **パッケージ内の実在確認はテストで行う。** colorset がバンドルに含まれるかは
///    コンパイル時には分からない。Xcode は生成シンボル(`ColorResource`)でこれを型にするが、
///    その生成は Xcode のビルドシステムの機能で、CI で回す `swift build` では行われない。
///    そのため実在確認は段を下げて実行時(テスト)で行う。
///
/// `CaseIterable` にしてあるのは、テストが照合する一覧を手で保守しないため。
/// case を足せば `allCases` に自動で入るので、「色を追加したがテストに書き忘れた」が起きない。
enum BrandColor: String, CaseIterable {
    case brandAccent
    case brandAccentSubtle

    /// このパッケージのリソースバンドルから色を解決する。
    var color: Color {
        Color(rawValue, bundle: .module)
    }
}
