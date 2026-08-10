#!/bin/bash
# DocC のドキュメントを生成して開く。
#
#   ./Scripts/docs.sh          生成して Xcode のドキュメントビューアで開く
#   ./Scripts/docs.sh --serve  ブラウザで見られる形に変換してローカルに配信する
#
# 生成物は .build/docs 配下(gitignore 済み)。リポジトリには何も残さない。
set -eu

cd "$(dirname "$0")/.."

DERIVED=.build/docs
ARCHIVE=$DERIVED/Build/Products/Debug-iphoneos/DesignSystem.doccarchive

xcodebuild -scheme DesignSystem \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$DERIVED" \
    docbuild >/dev/null

if [ "${1:-}" = "--serve" ]; then
    SITE=.build/docs-site
    rm -rf "$SITE"
    # 静的配信できる形に変換する。ルート直下に置くので hosting-base-path は空。
    xcrun docc process-archive transform-for-static-hosting "$ARCHIVE" \
        --output-path "$SITE" >/dev/null
    echo "http://localhost:8000/documentation/designsystem"
    cd "$SITE"
    python3 -m http.server 8000
else
    open "$ARCHIVE"
fi
