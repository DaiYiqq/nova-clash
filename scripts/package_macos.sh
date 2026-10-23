#!/usr/bin/env bash
set -euo pipefail
APP_NAME="NovaClash"
VERSION="0.1.7"
DIST="dist"
mkdir -p "$DIST"

APP=$(find build/macos/Build/Products/Release -maxdepth 1 -name "*.app" | head -n 1)
if [ -n "$APP" ]; then
  hdiutil create -volname "${APP_NAME}" -srcfolder "$APP" -ov -format UDZO "$DIST/${APP_NAME}-${VERSION}-macos.dmg"
fi

# iOS 未签名产物（无法在 CI 签名，安装需自行签名或用 Xcode 打包）
IOS_APP=$(find build/ios/iphoneos -maxdepth 1 -name "*.app" 2>/dev/null | head -n 1)
if [ -n "$IOS_APP" ]; then
  (cd "$(dirname "$IOS_APP")" && zip -r "$OLDPWD/$DIST/${APP_NAME}-${VERSION}-ios-unsigned.zip" "$(basename "$IOS_APP")")
fi

echo "--- dist/ ---"
ls -la "$DIST"
