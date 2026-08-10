#!/bin/bash
# 一覧を PNG として書き出す。
#
#   ./Scripts/gallery.sh
#
# iOS シミュレータ上で GalleryContent を実際に描画し、ライトとダークの 2 枚を
# .build/gallery へ出す(gitignore 済み)。実装から描くので、画像が古くなることはない。
set -eu

cd "$(dirname "$0")/.."

OUT=${GALLERY_OUT:-$PWD/.build/gallery}
SIMULATOR=${SIMULATOR:-iPhone 17 Pro}

# 端末名だけでは、同じ名前が複数のランタイムに存在する環境で解決できないことがある。
# `xcrun simctl list devices available` の UDID を SIMULATOR_ID に渡すと確実に指定できる。
if [ -n "${SIMULATOR_ID:-}" ]; then
    DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
else
    DESTINATION="platform=iOS Simulator,name=$SIMULATOR"
fi

rm -rf "$OUT"

# TEST_RUNNER_ 接頭辞を付けた変数は、接頭辞を外してテストプロセスへ渡される。
# シミュレータ内で動くテストへ出力先を伝える手段がこれしかない。
TEST_RUNNER_GALLERY_EXPORT_PATH=$OUT \
xcodebuild test \
    -scheme DesignSystem \
    -destination "$DESTINATION" \
    -only-testing:DesignSystemTests/GalleryExportTests \
    -derivedDataPath .build/gallery-build \
    >/dev/null

ls "$OUT"
open "$OUT"
