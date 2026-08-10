# DesignSystem

ParkApp / BalloonPop / AnimalGarden から参照する、表示の語彙をまとめた Swift パッケージ。
余白・角丸・書体・色と、それらを組み合わせたボタンやカードのスタイルだけを持つ。

## 使う

アプリ側で Xcode の File → Add Package Dependencies を開き、このリポジトリの URL を入れる。
プライベートリポジトリなので、事前に Xcode の Settings → Accounts へ GitHub アカウントを
登録しておく。

```swift
import DesignSystem

struct ContentView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("見出し").font(.itemTitle)
            Button("保存") {}.buttonStyle(.primary)
        }
        .card()
        .screenPadding()
        .background(Color.surfaceBackground)
    }
}
```

## 開発中はローカル参照にする

URL で参照したままだと、色を 1 つ直すたびにコミット・タグ・アプリ側のバージョン更新という
往復が要る。トークンが固まるまでは、クローンしたフォルダを Xcode のプロジェクトへ
ドラッグして参照する。Xcode はローカルパッケージをリモート依存より優先するので、
編集がそのままアプリのビルドへ反映される。

```
~/work/
├─ DesignSystem/   ← ここを直接編集
├─ ParkApp/
├─ BalloonPop/
└─ AnimalGarden/
```

区切りが付いたらコミットし、`git tag 1.0.0` のように意味づけしてからリモート参照へ戻す。

## 何を入れて、何を入れないか

**入れる。** どのアプリでも意味が変わらないもの。余白の刻み、角丸、書体の役割、
ブランドの色、汎用のボタンとカード。

**入れない。** アプリ固有の概念を含むもの。判断基準は型名で、`PrimaryButtonStyle` は入り、
`BalloonCard` や `AnimalCard` は入らない。ここを緩めると 2 本目のアプリが 1 本目の語彙を
引きずり、共有する意味が無くなる。

**入れない。** Figma のファイル、書き出した PNG、画面のスクリーンショット。差分が読めず、
実装とずれていく。見た目の一覧は `Gallery.swift` のプレビューが実物から描くので、
古くなることがない。

## 色の扱い

OS が持っている色(背景、区切り線、本文)はそのまま借り、ブランド固有の色だけを
アセットカタログに置いている。背景を自前で作り直すと、OS 側のコントラスト設定や
外観の更新に追随できなくなるため。

利用側からはどちらも `Color.surfaceBackground` / `Color.brandAccent` という同じ形なので、
後から出自を入れ替えても呼び出し側は変わらない。

色を追加するときは 2 か所を対で触る。

1. `Sources/DesignSystem/Resources/Colors.xcassets/` に `<名前>.colorset` を作る(ダーク用の値も入れる)
2. `BrandColor` に同名の case を足し、`Color+Tokens.swift` へ公開用の静的メンバを書く

順序を間違えても `swift test` が食い違いを検出する。

## 対応バージョン

`Package.swift` の下限は iOS 18。これは参照するアプリのうち最も低い AnimalGarden に
合わせたもので、この下限がある限り iOS 26 で入った API は `if #available` なしには使えない。
AnimalGarden を 26 へ上げれば、ここも上げられる。

## テスト

```
swift test
```

`BrandColor` の case とアセットカタログの colorset が過不足なく対応することを両方向で確認する。
実行時に色が解決できるかは検査していない。SwiftPM のコマンドラインビルドはアセットカタログを
`actool` でコンパイルせずそのままコピーするため、`swift test` の環境では名前解決が常に失敗する
(Xcode 経由のビルドとは成果物の形が違う)。色の値そのものは `Gallery` のプレビューで目視する。
